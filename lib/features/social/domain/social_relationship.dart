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
  final bool isBlockedByMe;
  final bool hasBlockedMe;
  final bool isBlocked;
  final String blockStatus;

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
    this.isBlockedByMe = false,
    this.hasBlockedMe = false,
    this.isBlocked = false,
    this.blockStatus = '',
    this.status,
    this.targetTotalFollowers,
    this.currentTotalFollowing,
  });

  bool get canInteract =>
      !isSelf && !isBlocked && !isBlockedByMe && !hasBlockedMe;

  bool get canFollow => canInteract && !isFollowing;
  bool get canUnfollow => canInteract && isFollowing;

  SocialRelationship copyWith({
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    String? relationshipStatus,
    String? actionLabel,
    bool? isBlockedByMe,
    bool? hasBlockedMe,
    bool? isBlocked,
    String? blockStatus,
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
      isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
      hasBlockedMe: hasBlockedMe ?? this.hasBlockedMe,
      isBlocked: isBlocked ?? this.isBlocked,
      blockStatus: blockStatus ?? this.blockStatus,
      status: status ?? this.status,
      targetTotalFollowers: targetTotalFollowers ?? this.targetTotalFollowers,
      currentTotalFollowing:
          currentTotalFollowing ?? this.currentTotalFollowing,
    );
  }
}
