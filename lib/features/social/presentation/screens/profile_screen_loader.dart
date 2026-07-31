part of 'profile_screen.dart';

final _profileViewDataProvider =
    FutureProvider.family<_ProfileViewData, _ProfileRequest>((ref, request) {
      return _ProfileLoader(ref).loadProfile(request);
    });

final _profilePanelProvider = FutureProvider.autoDispose
    .family<List<Short>, _ProfilePanelRequest>((ref, request) async {
      // A panel load is started imperatively from the profile scaffold. Keep
      // the auto-disposed provider alive only until that request settles so a
      // frame boundary cannot cancel the Future being awaited by the widget.
      final keepAliveLink = ref.keepAlive();
      try {
        return await _ProfileLoader(ref).loadPanel(request);
      } finally {
        keepAliveLink.close();
      }
    });

class _ProfileLoader {
  final Ref ref;

  const _ProfileLoader(this.ref);

  Future<_ProfileViewData> loadProfile(_ProfileRequest request) async {
    final bool isOwnProfile = _sameUser(
      request.targetUser,
      request.currentUserEmail,
    );

    final Map<String, dynamic> profile = await _loadProfilePayload(
      request,
      isOwnProfile: isOwnProfile,
    );

    final bool isDeleted = _bool(profile['is_deleted']);
    final bool isDeactivated = _bool(profile['is_deactivated']);
    final bool isBlockedByMe = _bool(profile['is_blocked_by_me']);
    final bool hasBlockedMe = _bool(profile['has_blocked_me']);
    final bool isBlocked =
        _bool(profile['is_blocked']) || isBlockedByMe || hasBlockedMe;
    final bool contentAvailable = !isDeleted && !isDeactivated && !isBlocked;

    // A successful get_profile response is authoritative for the requested
    // account. The backend may canonicalize an email/reference to a public ID,
    // so the frontend must not reject the payload because those strings differ.
    final String profileUser = _firstNonEmpty(<Object?>[
      profile['account_id'],
      profile['user'],
      profile['target_user'],
      request.targetUser,
    ]);
    final String displayName = _firstNonEmpty(<Object?>[
      profile['display_name'],
      profile['full_name'],
      profile['name'],
      request.fallbackDisplayName,
      isOwnProfile ? request.currentDisplayName : null,
      'AOS User',
    ]);
    final String rawAvatar = _firstNonEmpty(<Object?>[
      profile['avatar'],
      profile['user_image'],
      profile['image'],
      request.fallbackAvatar,
      isOwnProfile ? request.currentAvatar : null,
    ]);
    final String bio = _firstNonEmpty(<Object?>[
      profile['bio'],
      isOwnProfile ? request.currentBio : null,
    ]);

    final bool canInteract = !isOwnProfile && contentAvailable;

    final bool isFollowing = _bool(profile['is_following']);
    final bool isFollowedBy = _bool(profile['is_followed_by']);
    final bool isFriend =
        _bool(profile['is_friend']) || (isFollowing && isFollowedBy);
    final String relationshipStatus = _firstNonEmpty(<Object?>[
      profile['relationship_status'],
    ]);
    final String followActionLabel = _normalizeFollowActionLabel(
      _firstNonEmpty(<Object?>[profile['action_label']]),
      isFollowing: isFollowing,
      isFollowedBy: isFollowedBy,
      isFriend: isFriend,
      relationshipStatus: relationshipStatus,
    );

    final Map<String, dynamic> seller = asJsonMap(profile['seller']);
    final bool isSeller = _bool(seller['is_seller']);
    final String sellerId = _firstNonEmpty(<Object?>[
      seller['seller_id'],
      seller['name'],
    ]);

    final String liveId = _firstNonEmpty(<Object?>[profile['live_id']]);
    final bool isLive =
        !isDeleted &&
        !isDeactivated &&
        _bool(profile['is_live']) &&
        liveId.isNotEmpty;

    return _ProfileViewData(
      user: profileUser,
      displayName: displayName,
      username: isDeleted || isDeactivated
          ? ''
          : _usernameFromEmail(profileUser),
      avatarUrl: isDeleted || isDeactivated ? null : buildFileUrl(rawAvatar),
      bio: isDeleted || isDeactivated ? '' : bio,
      isOwnProfile: isOwnProfile,
      isLive: isLive,
      liveId: isLive ? liveId : null,
      followingCount: _nonNegativeInt(
        profile['following_count'] ?? profile['total_following'],
      ),
      followersCount: _nonNegativeInt(
        profile['followers_count'] ?? profile['total_followers'],
      ),
      friendsCount: _nonNegativeInt(
        profile['friends_count'] ?? profile['total_friends'],
      ),
      likesCount: _nonNegativeInt(
        profile['total_short_likes'] ??
            profile['total_likes'] ??
            profile['like_count'],
      ),
      isVerified:
          !isDeleted &&
          !isDeactivated &&
          (_bool(profile['is_verified']) ||
              (isOwnProfile && request.currentIsVerified)),
      posts: const <Short>[],
      reposted: const <Short>[],
      privateShorts: const <Short>[],
      saved: const <Short>[],
      liked: const <Short>[],
      isSeller: isSeller,
      sellerId: sellerId.isEmpty ? null : sellerId,
      isFollowing: isFollowing || isFriend,
      followActionLabel: followActionLabel,
      canInteract: canInteract,
      contentAvailable: contentAvailable,
    );
  }

  Future<List<Short>> loadPanel(_ProfilePanelRequest request) async {
    switch (request.panel) {
      case _ProfilePanel.posts:
        final List<Short> posts = await _loadPosts(
          request.targetUser,
          isOwnProfile: request.isOwnProfile,
        );
        return posts
            .where((Short short) => !short.isDeleted && !_isPrivateShort(short))
            .toList(growable: false);
      case _ProfilePanel.privateShorts:
        if (!request.isOwnProfile) return const <Short>[];
        final List<Short> posts = await _loadPosts(
          request.targetUser,
          isOwnProfile: true,
        );
        return posts
            .where((Short short) => !short.isDeleted && _isPrivateShort(short))
            .toList(growable: false);
      case _ProfilePanel.reposted:
        return _loadShortPanel(
          ApiEndpoints.repostedShorts,
          targetUser: request.targetUser,
        );
      case _ProfilePanel.saved:
        if (!request.isOwnProfile) return const <Short>[];
        return _loadShortPanel(ApiEndpoints.savedShorts);
      case _ProfilePanel.liked:
        if (!request.isOwnProfile) return const <Short>[];
        return _loadShortPanel(ApiEndpoints.likedShorts);
    }
  }

  Future<Map<String, dynamic>> _loadProfilePayload(
    _ProfileRequest request, {
    required bool isOwnProfile,
  }) async {
    final Either<Failure, Map<String, dynamic>> result = await ref
        .read(accountsApiProvider)
        .getProfile(targetUser: isOwnProfile ? null : request.targetUser);

    if (result.isLeft) throw result.leftOrNull!;

    final Map<String, dynamic> profile = _extractData(result.rightOrNull);
    if (profile.isEmpty) {
      throw const Failure('Invalid profile response.', type: FailureType.parse);
    }
    return profile;
  }

  Future<List<Short>> _loadPosts(
    String targetUser, {
    required bool isOwnProfile,
  }) {
    return _loadShortPanel(
      isOwnProfile ? ApiEndpoints.myShorts : ApiEndpoints.userShorts,
      targetUser: isOwnProfile ? null : targetUser,
      onlyCreator: true,
    );
  }

  Future<List<Short>> _loadShortPanel(
    String endpoint, {
    String? targetUser,
    bool onlyCreator = false,
  }) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            endpoint,
            queryParameters: <String, dynamic>{
              if (targetUser != null && targetUser.trim().isNotEmpty)
                'user': targetUser.trim(),
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
          .where((Short short) {
            final creatorUser = short.creator.user.trim().toLowerCase();
            if (creatorUser.isEmpty) return true;
            final String? cleanTarget = targetUser?.trim().toLowerCase();
            return cleanTarget == null ||
                cleanTarget.isEmpty ||
                creatorUser == cleanTarget;
          })
          .toList(growable: false);
    } catch (_) {
      return const <Short>[];
    }
  }

  static Map<String, dynamic> _extractData(Object? payload) {
    final Map<String, dynamic> root = asJsonMap(payload);
    final Map<String, dynamic> directData = asJsonMap(root['data']);
    if (directData.isNotEmpty) return directData;

    final Map<String, dynamic> message = asJsonMap(root['message']);
    final Map<String, dynamic> messageData = asJsonMap(message['data']);
    if (messageData.isNotEmpty) return messageData;
    if (message.isNotEmpty) return message;

    return root;
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

  static bool _isPrivateShort(Short short) {
    final String audience = short.audience.trim().toLowerCase();
    return audience == 'only_me' || audience == 'private';
  }

  static String _normalizeFollowActionLabel(
    String raw, {
    required bool isFollowing,
    required bool isFollowedBy,
    required bool isFriend,
    required String relationshipStatus,
  }) {
    final String status = relationshipStatus.trim().toLowerCase();
    final String clean = raw.trim().toLowerCase();

    if (isFriend || status == 'friends' || clean == 'friends') {
      return 'Friends';
    }
    if (isFollowing || status == 'following' || clean == 'following') {
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
    final String clean = value.toString().trim().toLowerCase();
    return clean == '1' || clean == 'true' || clean == 'yes';
  }

  static int _nonNegativeInt(dynamic value, {int fallback = 0}) {
    final int parsed = switch (value) {
      final int number => number,
      final num number => number.toInt(),
      _ => int.tryParse(value?.toString() ?? '') ?? fallback,
    };
    return parsed < 0 ? 0 : parsed;
  }
}
