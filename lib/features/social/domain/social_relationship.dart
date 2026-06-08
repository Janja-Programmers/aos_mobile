import 'package:flutter/foundation.dart';

@immutable
class SocialRelationship {
  final String targetUser;
  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final String relationshipStatus;
  final String actionLabel;

  /// Returned by toggle_follow only.
  final String? status;
  final int? targetTotalFollowers;
  final int? currentTotalFollowing;

  const SocialRelationship({
    required this.targetUser,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
    this.status,
    this.targetTotalFollowers,
    this.currentTotalFollowing,
  });

  bool get canFollow => !isSelf && !isFollowing;
  bool get canUnfollow => !isSelf && isFollowing;

  SocialRelationship copyWith({
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    String? relationshipStatus,
    String? actionLabel,
    String? status,
    int? targetTotalFollowers,
    int? currentTotalFollowing,
  }) {
    return SocialRelationship(
      targetUser: targetUser ?? this.targetUser,
      isSelf: isSelf ?? this.isSelf,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isFriend: isFriend ?? this.isFriend,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      actionLabel: actionLabel ?? this.actionLabel,
      status: status ?? this.status,
      targetTotalFollowers: targetTotalFollowers ?? this.targetTotalFollowers,
      currentTotalFollowing:
          currentTotalFollowing ?? this.currentTotalFollowing,
    );
  }
}
