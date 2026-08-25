part of 'profile_screen.dart';

enum _AvatarPhotoAction { gallery, camera, remove }

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
  final String currentAccountId;
  final String currentDisplayName;
  final String currentAvatar;
  final String? currentBio;
  final bool currentIsVerified;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const _ProfileRequest({
    required this.targetUser,
    required this.currentUserEmail,
    required this.currentAccountId,
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
        other.currentAccountId == currentAccountId &&
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
    currentAccountId,
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
  final bool canInteract;
  final bool contentAvailable;

  bool get canVisitSellerStore =>
      canInteract && isSeller && (sellerId?.trim().isNotEmpty ?? false);

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
    required this.canInteract,
    required this.contentAvailable,
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
      'AOS User',
    ]);
    final avatar = _ProfileLoader._firstNonEmpty([
      fallbackAvatar,
      isOwnProfile ? currentAvatar : null,
    ]);

    return _ProfileViewData(
      user: targetUser,
      displayName: displayName,
      username: '',
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
      canInteract: false,
      contentAvailable: true,
    );
  }
}

@immutable
class _ProfilePanelRequest {
  final String targetUser;
  final bool isOwnProfile;
  final _ProfilePanel panel;

  const _ProfilePanelRequest({
    required this.targetUser,
    required this.isOwnProfile,
    required this.panel,
  });

  @override
  bool operator ==(Object other) {
    return other is _ProfilePanelRequest &&
        other.targetUser == targetUser &&
        other.isOwnProfile == isOwnProfile &&
        other.panel == panel;
  }

  @override
  int get hashCode => Object.hash(targetUser, isOwnProfile, panel);
}
