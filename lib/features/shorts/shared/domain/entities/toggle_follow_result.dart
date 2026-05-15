// features/shorts/shared/domain/entities/toggle_follow_result.dart

import 'package:equatable/equatable.dart';

class ToggleFollowResult extends Equatable {
  final String targetUser;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final String relationshipStatus;
  final String actionLabel;

  const ToggleFollowResult({
    required this.targetUser,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
  });

  @override
  List<Object?> get props => [
    targetUser,
    isFollowing,
    isFollowedBy,
    isFriend,
    relationshipStatus,
    actionLabel,
  ];
}
