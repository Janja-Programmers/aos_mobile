part of 'profile_screen.dart';

enum _AvatarPhotoAction { gallery, camera }

enum _ProfilePanel { posts, privateShorts, reposted, saved, liked }

extension _ProfilePanelX on _ProfilePanel {
  String get label {
    switch (this) {
      case _ProfilePanel.posts:
        return 'Posts';
      case _ProfilePanel.reposted:
        return 'Reposted';
      case _ProfilePanel.privateShorts:
        return 'Private';
      case _ProfilePanel.saved:
        return 'Saved';
      case _ProfilePanel.liked:
        return 'Liked';
    }
  }

  IconData get icon {
    switch (this) {
      case _ProfilePanel.posts:
        return Icons.grid_view_rounded;
      case _ProfilePanel.reposted:
        return Icons.repeat_rounded;
      case _ProfilePanel.privateShorts:
        return Icons.lock_outline_rounded;
      case _ProfilePanel.saved:
        return Icons.bookmark_border_rounded;
      case _ProfilePanel.liked:
        return Icons.favorite_border_rounded;
    }
  }
}

@immutable
class _ProfileRequest {
  final String targetUser;
  final String currentUserEmail;
  final String currentDisplayName;
  final String currentAvatar;
  final String? currentBio;
  final bool currentIsVerified;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const _ProfileRequest({
    required this.targetUser,
    required this.currentUserEmail,
    required this.currentDisplayName,
    required this.currentAvatar,
    this.currentBio,
    required this.currentIsVerified,
    this.fallbackDisplayName,
    this.fallbackAvatar,
  });

  @override
  bool operator ==(Object other) {
    return other is _ProfileRequest &&
        other.targetUser == targetUser &&
        other.currentUserEmail == currentUserEmail &&
        other.currentDisplayName == currentDisplayName &&
        other.currentAvatar == currentAvatar &&
        other.currentBio == currentBio &&
        other.currentIsVerified == currentIsVerified &&
        other.fallbackDisplayName == fallbackDisplayName &&
        other.fallbackAvatar == fallbackAvatar;
  }

  @override
  int get hashCode => Object.hash(
    targetUser,
    currentUserEmail,
    currentDisplayName,
    currentAvatar,
    currentBio,
    currentIsVerified,
    fallbackDisplayName,
    fallbackAvatar,
  );
}

@immutable
class _ProfileViewData {
  final String user;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String bio;
  final bool isOwnProfile;
  final bool isLive;
  final String? liveId;
  final int followingCount;
  final int followersCount;
  final int friendsCount;
  final int likesCount;
  final bool isVerified;
  final List<Short> posts;
  final List<Short> reposted;
  final List<Short> privateShorts;
  final List<Short> saved;
  final List<Short> liked;
  final bool isSeller;
  final String? sellerId;
  final bool isFollowing;
  final String followActionLabel;

  bool get canVisitSellerStore =>
      !isOwnProfile && isSeller && (sellerId?.trim().isNotEmpty ?? false);

  const _ProfileViewData({
    required this.user,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.isOwnProfile,
    required this.isLive,
    required this.liveId,
    required this.followingCount,
    required this.followersCount,
    required this.friendsCount,
    required this.likesCount,
    required this.isVerified,
    required this.posts,
    required this.reposted,
    required this.privateShorts,
    required this.saved,
    required this.liked,
    required this.isSeller,
    required this.sellerId,
    required this.isFollowing,
    required this.followActionLabel,
  });

  factory _ProfileViewData.fallback({
    required String targetUser,
    required bool isOwnProfile,
    required String currentDisplayName,
    required String currentAvatar,
    required String? currentBio,
    required bool currentIsVerified,
    String? fallbackDisplayName,
    String? fallbackAvatar,
  }) {
    final displayName = _ProfileLoader._firstNonEmpty([
      fallbackDisplayName,
      isOwnProfile ? currentDisplayName : null,
      targetUser,
    ]);
    final avatar = _ProfileLoader._firstNonEmpty([
      fallbackAvatar,
      isOwnProfile ? currentAvatar : null,
    ]);

    return _ProfileViewData(
      user: targetUser,
      displayName: displayName,
      username: _usernameFromEmail(targetUser),
      avatarUrl: buildFileUrl(avatar),
      bio: isOwnProfile ? (currentBio?.trim() ?? '') : '',
      isOwnProfile: isOwnProfile,
      isLive: false,
      liveId: null,
      followingCount: 0,
      followersCount: 0,
      friendsCount: 0,
      likesCount: 0,
      isVerified: isOwnProfile && currentIsVerified,
      posts: const <Short>[],
      reposted: const <Short>[],
      privateShorts: const <Short>[],
      saved: const <Short>[],
      liked: const <Short>[],
      isSeller: false,
      sellerId: null,
      isFollowing: false,
      followActionLabel: 'Follow',
    );
  }
}

@immutable
class _SellerProfileLite {
  final String sellerId;
  final String user;

  const _SellerProfileLite({required this.sellerId, required this.user});
}

@immutable
class _RelationshipLite {
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final String relationshipStatus;
  final String actionLabel;
  final int? targetTotalFollowers;

  const _RelationshipLite({
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
    required this.targetTotalFollowers,
  });

  const _RelationshipLite.self()
    : isFollowing = false,
      isFollowedBy = false,
      isFriend = false,
      relationshipStatus = 'self',
      actionLabel = '',
      targetTotalFollowers = null;
}

String _usernameFromEmail(String value) {
  final clean = value.trim();
  if (clean.contains('@')) return clean.split('@').first;
  return clean;
}
