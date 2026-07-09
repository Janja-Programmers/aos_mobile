part of 'profile_screen.dart';

final _profileViewDataProvider =
    FutureProvider.family<_ProfileViewData, _ProfileRequest>((ref, request) {
      return _ProfileLoader(ref).load(request);
    });

class _ProfileLoader {
  final Ref ref;

  const _ProfileLoader(this.ref);

  Future<_ProfileViewData> load(_ProfileRequest request) async {
    final isOwnProfile = _sameUser(
      request.targetUser,
      request.currentUserEmail,
    );

    final profileFuture = _loadProfilePayload(request);
    final followingFuture = _loadConnectionTotal(
      ApiEndpoints.getFollowingEndpoint,
      request.targetUser,
    );
    final followersFuture = _loadConnectionTotal(
      ApiEndpoints.getFollowsEndpoint,
      request.targetUser,
    );
    final friendsFuture = _loadConnectionTotal(
      ApiEndpoints.getFriendsEndpoint,
      request.targetUser,
    );
    final postsFuture = _loadPosts(
      request.targetUser,
      isOwnProfile: isOwnProfile,
    );
    final repostedFuture = _loadShortPanel(
      ApiEndpoints.repostedShorts,
      request.targetUser,
    );
    final relationshipFuture = isOwnProfile
        ? Future<_RelationshipLite>.value(const _RelationshipLite.self())
        : _loadRelationship(request.targetUser);
    final sellerFuture = isOwnProfile
        ? Future<_SellerProfileLite?>.value()
        : _loadSellerProfile(request.targetUser);

    final results = await Future.wait<dynamic>([
      profileFuture,
      followingFuture,
      followersFuture,
      friendsFuture,
      postsFuture,
      repostedFuture,
      relationshipFuture,
      sellerFuture,
    ]);

    final profile = results[0] as Map<String, dynamic>;
    final following = results[1] as int?;
    final followers = results[2] as int?;
    final friends = results[3] as int?;
    final allPosts = results[4] as List<Short>;
    final reposted = results[5] as List<Short>;
    final relationship = results[6] as _RelationshipLite;
    final seller = results[7] as _SellerProfileLite?;

    final posts = allPosts
        .where((short) => !short.isDeleted && !_isPrivateShort(short))
        .toList(growable: false);
    final privateShorts = isOwnProfile
        ? allPosts
              .where((short) => !short.isDeleted && _isPrivateShort(short))
              .toList(growable: false)
        : const <Short>[];

    final profileBelongsToTarget = _profileBelongsToTarget(
      profile,
      request.targetUser,
      isOwnProfile,
    );

    final displayName = _firstNonEmpty([
      if (profileBelongsToTarget) profile['display_name'],
      if (profileBelongsToTarget) profile['full_name'],
      if (profileBelongsToTarget) profile['name'],
      request.fallbackDisplayName,
      isOwnProfile ? request.currentDisplayName : null,
      request.targetUser,
    ]);

    final rawAvatar = _firstNonEmpty([
      if (profileBelongsToTarget) profile['avatar'],
      if (profileBelongsToTarget) profile['user_image'],
      if (profileBelongsToTarget) profile['image'],
      request.fallbackAvatar,
      isOwnProfile ? request.currentAvatar : null,
    ]);

    final bio = _firstNonEmpty([
      if (profileBelongsToTarget) profile['bio'],
      if (profileBelongsToTarget) profile['about'],
      if (profileBelongsToTarget) profile['description'],
      isOwnProfile ? request.currentBio : null,
    ]);

    final isVerified =
        profileBelongsToTarget &&
        (_bool(profile['is_verified']) ||
            _bool(profile['verified']) ||
            _bool(profile['identity_verified']) ||
            _bool(profile['is_identity_verified']));

    final liveId = profileBelongsToTarget
        ? _firstNonEmpty([profile['live_id']])
        : '';
    final isLive =
        profileBelongsToTarget &&
        _bool(profile['is_live']) &&
        liveId.isNotEmpty;

    final isFollowedBy = relationship.isFollowedBy ||
        (profileBelongsToTarget && _bool(profile['is_followed_by']));
    final isFollowing = relationship.isFollowing ||
        (profileBelongsToTarget && _bool(profile['is_following']));
    final isFriend = relationship.isFriend ||
        (profileBelongsToTarget && _bool(profile['is_friend'])) ||
        (isFollowing && isFollowedBy);
    final relationshipStatus = _firstNonEmpty([
      relationship.relationshipStatus,
      if (profileBelongsToTarget) profile['relationship_status'],
    ]);
    final followActionLabel = _normalizeFollowActionLabel(
      _firstNonEmpty([
        relationship.actionLabel,
        if (profileBelongsToTarget) profile['action_label'],
      ]),
      isFollowing: isFollowing,
      isFollowedBy: isFollowedBy,
      isFriend: isFriend,
      relationshipStatus: relationshipStatus,
    );

    final profileUser = _firstNonEmpty([
      if (profileBelongsToTarget) profile['user'],
      if (profileBelongsToTarget) profile['email'],
      if (profileBelongsToTarget) profile['target_user'],
      seller?.user,
      request.targetUser,
    ]);

    return _ProfileViewData(
      user: profileUser,
      displayName: displayName,
      username: _usernameFromEmail(profileUser),
      avatarUrl: buildFileUrl(rawAvatar),
      bio: bio,
      isOwnProfile: isOwnProfile,
      isLive: isLive,
      liveId: liveId.isEmpty ? null : liveId,
      followingCount: following ?? _int(profile['total_following']) ?? 0,
      followersCount:
          followers ??
          _int(profile['total_followers']) ??
          relationship.targetTotalFollowers ??
          0,
      friendsCount: friends ?? _int(profile['total_friends']) ?? 0,
      likesCount:
          _int(profile['total_short_likes']) ??
          _int(profile['total_likes']) ??
          _int(profile['like_count']) ??
          allPosts.fold<int>(0, (sum, short) => sum + short.metrics.likeCount),
      isVerified: isVerified || (isOwnProfile && request.currentIsVerified),
      posts: posts,
      reposted: reposted,
      privateShorts: privateShorts,
      isSeller: seller != null,
      sellerId: seller?.sellerId,
      isFollowing: isFollowing || isFriend,
      followActionLabel: followActionLabel,
    );
  }

  Future<Map<String, dynamic>> _loadProfilePayload(
    _ProfileRequest request,
  ) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            ApiEndpoints.getProfileEndpoint,
            queryParameters: _targetQuery(request.targetUser),
          );
      final unwrapped = unwrapFrappe(res);

      if (unwrapped.isLeft) return <String, dynamic>{};

      final raw = _extractData(unwrapped.rightOrNull);
      return asJsonMap(raw);
    } catch (_) {}

    return <String, dynamic>{};
  }

  Future<int?> _loadConnectionTotal(String endpoint, String targetUser) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            endpoint,
            queryParameters: {
              ..._targetQuery(targetUser),
              'limit': 1,
              'start': 0,
            },
          );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return null;

      final raw = _extractData(unwrapped.rightOrNull);
      return _int(raw['total']);
    } catch (_) {}

    return null;
  }

  Future<_RelationshipLite> _loadRelationship(String targetUser) async {
    try {
      final relationship = await ref
          .read(socialRepositoryProvider)
          .getRelationshipStatus(targetUser: targetUser);

      if (relationship.isRight) {
        final value = relationship.rightOrNull!;
        return _RelationshipLite(
          isFollowing: value.isFollowing,
          isFollowedBy: value.isFollowedBy,
          isFriend: value.isFriend,
          relationshipStatus: value.relationshipStatus,
          actionLabel: value.actionLabel,
          targetTotalFollowers: value.targetTotalFollowers,
        );
      }
    } catch (_) {}

    return const _RelationshipLite(
      isFollowing: false,
      isFollowedBy: false,
      isFriend: false,
      relationshipStatus: '',
      actionLabel: 'Follow',
      targetTotalFollowers: null,
    );
  }

  Future<_SellerProfileLite?> _loadSellerProfile(String targetUser) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            ApiEndpoints.getSellerEndpoint,
            queryParameters: {'seller': targetUser},
          );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return null;

      final payload = unwrapped.rightOrNull ?? <String, dynamic>{};
      if (_isFailurePayload(payload)) return null;

      final data = _extractData(payload);
      if (_isFailurePayload(data)) return null;

      final sellerId = _firstNonEmpty([data['seller']]);
      final user = _firstNonEmpty([data['user']]);

      if (sellerId.isEmpty || user.isEmpty || !_sameUser(user, targetUser)) {
        return null;
      }

      return _SellerProfileLite(sellerId: sellerId, user: user);
    } catch (_) {
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
            queryParameters: {
              ..._targetQuery(targetUser),
              'owner': targetUser,
              'limit': 30,
            },
          );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return const <Short>[];

      final data = _extractData(unwrapped.rightOrNull);
      final rawItems = data['items'] ?? data['shorts'] ?? data['data'];

      final list = asJsonMapList(rawItems)
          .map(ShortModel.fromJson)
          .map(ShortMapper.toDomain)
          .toList(growable: false);

      if (!onlyCreator) return list;

      return list
          .where((short) {
            final creatorUser = short.creator.user.trim().toLowerCase();
            if (creatorUser.isEmpty) return true;
            return creatorUser == targetUser.trim().toLowerCase();
          })
          .toList(growable: false);
    } catch (_) {
      return const <Short>[];
    }
  }

  static Map<String, dynamic> _targetQuery(String targetUser) {
    return {'user': targetUser, 'target_user': targetUser};
  }

  static Map<String, dynamic> _extractData(Object? payload) {
    final data = asJsonMap(payload);
    final innerData = asJsonMap(data['data']);
    if (innerData.isNotEmpty) return innerData;

    final message = asJsonMap(data['message']);
    if (message.isNotEmpty) {
      final messageData = asJsonMap(message['data']);
      return messageData.isNotEmpty ? messageData : message;
    }

    return data;
  }

  static bool _profileBelongsToTarget(
    Map<String, dynamic> profile,
    String targetUser,
    bool isOwnProfile,
  ) {
    if (isOwnProfile) return true;

    final target = targetUser.trim().toLowerCase();
    final identity = _firstNonEmpty([
      profile['user'],
      profile['email'],
      profile['target_user'],
    ]).trim().toLowerCase();

    if (identity.isEmpty) return false;
    return identity == target;
  }

  static bool _sameUser(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final clean = value?.toString().trim();
      if (clean != null && clean.isNotEmpty && clean.toLowerCase() != 'null') {
        return clean;
      }
    }
    return '';
  }

  static bool _isFailurePayload(Map<String, dynamic> payload) {
    if (!payload.containsKey('ok')) return false;

    final ok = payload['ok'];
    if (ok is bool) return !ok;
    if (ok is num) return ok == 0;

    final clean = ok?.toString().trim().toLowerCase() ?? '';
    return clean == 'false' || clean == '0' || clean == 'no';
  }

  static bool _isPrivateShort(Short short) {
    final audience = short.audience.trim().toLowerCase();
    final visibility = short.visibilityStatus.trim().toLowerCase();

    return (audience.isNotEmpty && audience != 'everyone') ||
        (visibility.isNotEmpty && visibility != 'visible');
  }

  static String _normalizeFollowActionLabel(
    String raw, {
    required bool isFollowing,
    required bool isFollowedBy,
    required bool isFriend,
    required String relationshipStatus,
  }) {
    final status = relationshipStatus.trim().toLowerCase();
    final clean = raw.trim().toLowerCase();

    if (isFriend ||
        isFollowing ||
        status == 'friends' ||
        status == 'following') {
      return 'Following';
    }

    if (isFollowedBy || status == 'followed_by' || clean == 'follow back') {
      return 'Follow back';
    }

    return 'Follow';
  }

  static bool _bool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    final clean = value.toString().trim().toLowerCase();
    return clean == '1' ||
        clean == 'true' ||
        clean == 'yes' ||
        clean == 'approved';
  }

  static int? _int(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

