part of 'profile_screen.dart';

final _profileViewDataProvider =
    FutureProvider.family<_ProfileViewData, _ProfileRequest>((ref, request) {
      return _ProfileLoader(ref).load(request);
    });

class _ProfileLoader {
  const _ProfileLoader(this.ref);

  final Ref ref;

  Future<_ProfileViewData> load(_ProfileRequest request) async {
    final bool isOwnProfile = _sameUser(
      request.targetUser,
      request.currentUserEmail,
    );
    final AccountProfileSnapshot profile = await _loadProfile(request);

    if (!_sameUser(profile.user, request.targetUser)) {
      throw const Failure(
        'Profile response did not match the requested user.',
        type: FailureType.parse,
      );
    }

    final bool interactionAllowed = profile.allowsSocialInteraction;
    final bool contentAllowed = interactionAllowed && !profile.isDeleted;

    final Future<List<Short>> postsFuture = contentAllowed
        ? _loadPosts(request.targetUser, isOwnProfile: isOwnProfile)
        : Future<List<Short>>.value(const <Short>[]);
    final Future<List<Short>> repostedFuture = contentAllowed
        ? _loadShortPanel(ApiEndpoints.repostedShorts, request.targetUser)
        : Future<List<Short>>.value(const <Short>[]);
    final Future<List<Short>> savedFuture = isOwnProfile && contentAllowed
        ? _loadShortPanel(ApiEndpoints.savedShorts, request.targetUser)
        : Future<List<Short>>.value(const <Short>[]);
    final Future<List<Short>> likedFuture = isOwnProfile && contentAllowed
        ? _loadShortPanel(ApiEndpoints.likedShorts, request.targetUser)
        : Future<List<Short>>.value(const <Short>[]);
    final Future<_SellerProfileLite?> sellerFuture =
        !isOwnProfile && contentAllowed
        ? _loadSellerProfile(request.targetUser)
        : Future<_SellerProfileLite?>.value();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      postsFuture,
      repostedFuture,
      savedFuture,
      likedFuture,
      sellerFuture,
    ]);

    final List<Short> allPosts = results[0] as List<Short>;
    final List<Short> reposted = results[1] as List<Short>;
    final List<Short> saved = results[2] as List<Short>;
    final List<Short> liked = results[3] as List<Short>;
    final _SellerProfileLite? seller = results[4] as _SellerProfileLite?;

    final List<Short> posts = allPosts
        .where((Short short) => !short.isDeleted && !_isPrivateShort(short))
        .toList(growable: false);
    final List<Short> privateShorts = isOwnProfile
        ? allPosts
              .where(
                (Short short) => !short.isDeleted && _isPrivateShort(short),
              )
              .toList(growable: false)
        : const <Short>[];

    final String displayName = _firstNonEmpty(<Object?>[
      profile.fullName,
      request.fallbackDisplayName,
      isOwnProfile ? request.currentDisplayName : null,
      request.targetUser,
    ]);
    final String rawAvatar = _firstNonEmpty(<Object?>[
      profile.userImage,
      request.fallbackAvatar,
      isOwnProfile ? request.currentAvatar : null,
    ]);
    final String actionLabel = _relationshipActionLabel(profile);

    return _ProfileViewData(
      user: profile.user,
      displayName: displayName,
      username: _usernameFromEmail(profile.user),
      avatarUrl: buildFileUrl(rawAvatar),
      bio: profile.bio,
      isOwnProfile: isOwnProfile,
      isDeleted: profile.isDeleted,
      isBlocked:
          profile.isBlocked || profile.isBlockedByMe || profile.hasBlockedMe,
      canMessage: !isOwnProfile && interactionAllowed,
      canToggleFollow: !isOwnProfile && interactionAllowed,
      canOpenConnections: isOwnProfile && interactionAllowed,
      isLive: profile.hasLiveRoom,
      liveId: profile.hasLiveRoom ? profile.liveId : null,
      followingCount: profile.totalFollowing,
      followersCount: profile.totalFollowers,
      friendsCount: profile.totalFriends,
      likesCount: profile.totalShortLikes,
      isVerified:
          profile.isVerified || (isOwnProfile && request.currentIsVerified),
      posts: posts,
      reposted: reposted,
      privateShorts: privateShorts,
      saved: saved,
      liked: liked,
      isSeller: seller != null,
      sellerId: seller?.sellerId,
      isFollowing: profile.isFollowing || profile.isFriend,
      followActionLabel: actionLabel,
    );
  }

  Future<AccountProfileSnapshot> _loadProfile(_ProfileRequest request) async {
    final Either<Failure, Map<String, dynamic>> result = await ref
        .read(accountsApiProvider)
        .getProfile(targetUser: request.targetUser);

    if (result.isLeft) {
      throw result.leftOrNull ?? const Failure('Failed to load profile.');
    }

    final Map<String, dynamic> payload =
        result.rightOrNull ?? <String, dynamic>{};
    if (payload['ok'] != true) {
      throw Failure.fromServerPayload(
        payload,
        fallbackMessage: 'Failed to load profile.',
      );
    }

    final Map<String, dynamic> data = asJsonMap(payload['data']);
    if (data.isEmpty) {
      throw const Failure(
        'Invalid profile response format.',
        type: FailureType.parse,
      );
    }

    final AccountProfileSnapshot snapshot = AccountProfileSnapshot.fromJson(
      data,
    );
    if (snapshot.user.isEmpty) {
      throw const Failure(
        'Invalid profile response format.',
        type: FailureType.parse,
      );
    }
    return snapshot;
  }

  Future<_SellerProfileLite?> _loadSellerProfile(String targetUser) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            ApiEndpoints.getSellerEndpoint,
            queryParameters: <String, dynamic>{'seller': targetUser},
          );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return null;

      final Map<String, dynamic> payload =
          unwrapped.rightOrNull ?? <String, dynamic>{};
      if (_isFailurePayload(payload)) return null;

      final Map<String, dynamic> data = _extractData(payload);
      if (_isFailurePayload(data)) return null;

      final String sellerId = _firstNonEmpty(<Object?>[data['seller']]);
      final String user = _firstNonEmpty(<Object?>[data['user']]);

      if (sellerId.isEmpty || user.isEmpty || !_sameUser(user, targetUser)) {
        return null;
      }

      return _SellerProfileLite(sellerId: sellerId, user: user);
    } on Exception {
      return null;
    }
  }

  Future<List<Short>> _loadPosts(
    String targetUser, {
    required bool isOwnProfile,
  }) {
    return _loadShortPanel(
      isOwnProfile ? ApiEndpoints.myShorts : ApiEndpoints.userShorts,
      targetUser,
      onlyCreator: true,
    );
  }

  Future<List<Short>> _loadShortPanel(
    String endpoint,
    String targetUser, {
    bool onlyCreator = false,
  }) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            endpoint,
            queryParameters: <String, dynamic>{
              ..._targetQuery(targetUser),
              'owner': targetUser,
              'limit': 30,
            },
          );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return const <Short>[];

      final Map<String, dynamic> data = _extractData(unwrapped.rightOrNull);
      final Object? rawItems = data['items'] ?? data['shorts'] ?? data['data'];

      final List<Short> list = asJsonMapList(rawItems)
          .map(ShortModel.fromJson)
          .map(ShortMapper.toDomain)
          .toList(growable: false);

      if (!onlyCreator) return list;

      return list
          .where((Short short) {
            final String creatorUser = short.creator.user.trim().toLowerCase();
            if (creatorUser.isEmpty) return true;
            return creatorUser == targetUser.trim().toLowerCase();
          })
          .toList(growable: false);
    } on Exception {
      return const <Short>[];
    }
  }

  static Map<String, dynamic> _targetQuery(String targetUser) {
    return <String, dynamic>{'user': targetUser, 'target_user': targetUser};
  }

  static Map<String, dynamic> _extractData(Object? payload) {
    final Map<String, dynamic> data = asJsonMap(payload);
    final Map<String, dynamic> innerData = asJsonMap(data['data']);
    if (innerData.isNotEmpty) return innerData;

    final Map<String, dynamic> message = asJsonMap(data['message']);
    if (message.isNotEmpty) {
      final Map<String, dynamic> messageData = asJsonMap(message['data']);
      return messageData.isNotEmpty ? messageData : message;
    }

    return data;
  }

  static bool _sameUser(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final Object? value in values) {
      final String? clean = value?.toString().trim();
      if (clean != null && clean.isNotEmpty && clean.toLowerCase() != 'null') {
        return clean;
      }
    }
    return '';
  }

  static bool _isFailurePayload(Map<String, dynamic> payload) {
    if (!payload.containsKey('ok')) return false;

    final Object? ok = payload['ok'];
    if (ok is bool) return !ok;
    if (ok is num) return ok == 0;

    final String clean = ok?.toString().trim().toLowerCase() ?? '';
    return clean == 'false' || clean == '0' || clean == 'no';
  }

  static bool _isPrivateShort(Short short) {
    final String audience = short.audience.trim().toLowerCase();
    return audience == 'only_me' || audience == 'private';
  }

  static String _relationshipActionLabel(AccountProfileSnapshot profile) {
    final String backendLabel = profile.actionLabel.trim();
    if (backendLabel.isNotEmpty) return backendLabel;

    switch (profile.relationshipStatus.trim().toLowerCase()) {
      case 'friends':
        return 'Friends';
      case 'following':
        return 'Following';
      case 'followed_by':
        return 'Follow Back';
      default:
        return 'Follow';
    }
  }
}
