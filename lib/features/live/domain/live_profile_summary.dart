import 'package:flutter/foundation.dart';

@immutable
class LiveProfileSummary {
  const LiveProfileSummary({
    required this.accountId,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.isVerified,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.isBlocked,
    required this.actionLabel,
  });

  final String accountId;
  final String displayName;
  final String? avatarUrl;
  final String bio;
  final bool isVerified;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final bool isBlocked;
  final String actionLabel;
}
