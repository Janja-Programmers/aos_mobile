import 'package:flutter/widgets.dart';

@immutable
class SocialFriend {
  final String user;
  final String fullName;
  final String? userImage;

  final int totalFollowers;
  final int totalFollowing;

  final bool isVerified;

  final DateTime? followedAt;
  final String targetUser;

  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;

  final String relationshipStatus;
  final String actionLabel;

  final DateTime? followedBackAt;

  const SocialFriend({
    required this.user,
    required this.fullName,
    this.userImage,
    this.totalFollowers = 0,
    this.totalFollowing = 0,
    this.isVerified = false,
    this.followedAt,
    required this.targetUser,
    this.isSelf = false,
    this.isFollowing = false,
    this.isFollowedBy = false,
    this.isFriend = false,
    this.relationshipStatus = '',
    this.actionLabel = '',
    this.followedBackAt,
  });

  String get displayName {
    final cleanName = fullName.trim();
    if (cleanName.isNotEmpty) return cleanName;

    final cleanUser = user.trim();
    if (cleanUser.isNotEmpty) return cleanUser;

    return 'AOS User';
  }

  String get initials {
    final clean = displayName.trim();
    if (clean.isEmpty) return '?';

    final parts = clean.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  bool get hasImage {
    final clean = userImage?.trim();
    return clean != null && clean.isNotEmpty;
  }

  SocialFriend copyWith({
    String? user,
    String? fullName,
    String? userImage,
    int? totalFollowers,
    int? totalFollowing,
    bool? isVerified,
    DateTime? followedAt,
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    String? relationshipStatus,
    String? actionLabel,
    DateTime? followedBackAt,
  }) {
    return SocialFriend(
      user: user ?? this.user,
      fullName: fullName ?? this.fullName,
      userImage: userImage ?? this.userImage,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalFollowing: totalFollowing ?? this.totalFollowing,
      isVerified: isVerified ?? this.isVerified,
      followedAt: followedAt ?? this.followedAt,
      targetUser: targetUser ?? this.targetUser,
      isSelf: isSelf ?? this.isSelf,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isFriend: isFriend ?? this.isFriend,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      actionLabel: actionLabel ?? this.actionLabel,
      followedBackAt: followedBackAt ?? this.followedBackAt,
    );
  }
}
