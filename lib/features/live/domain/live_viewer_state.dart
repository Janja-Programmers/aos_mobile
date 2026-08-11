import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/live/domain/live_cohost.dart';
import 'package:equatable/equatable.dart';

class LiveViewerState extends Equatable {
  final String? targetUser;

  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final bool isBlockedByMe;
  final bool hasBlockedMe;
  final bool isBlocked;

  final String relationshipStatus;
  final String actionLabel;
  final String blockStatus;
  final bool canFollow;
  final bool canMessage;
  final bool canCall;
  final bool canViewProfile;

  final bool isOwner;
  final bool isHost;
  final bool hasJoined;

  final bool canJoin;
  final bool canWatch;
  final bool canComment;
  final bool canReact;
  final bool canEnd;
  final bool canReport;
  final bool isCohost;
  final bool canRequestCohost;
  final bool canInviteCohost;
  final String? cohostStatus;
  final LiveCohost? cohostWorkflow;

  const LiveViewerState({
    required this.targetUser,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.isBlockedByMe,
    required this.hasBlockedMe,
    required this.isBlocked,
    required this.relationshipStatus,
    required this.actionLabel,
    required this.blockStatus,
    required this.canFollow,
    required this.canMessage,
    required this.canCall,
    required this.canViewProfile,
    required this.isOwner,
    required this.isHost,
    required this.hasJoined,
    required this.canJoin,
    required this.canWatch,
    required this.canComment,
    required this.canReact,
    required this.canEnd,
    required this.canReport,
    required this.isCohost,
    required this.canRequestCohost,
    required this.canInviteCohost,
    required this.cohostStatus,
    required this.cohostWorkflow,
  });

  factory LiveViewerState.initial() {
    return const LiveViewerState(
      targetUser: null,
      isSelf: false,
      isFollowing: false,
      isFollowedBy: false,
      isFriend: false,
      isBlockedByMe: false,
      hasBlockedMe: false,
      isBlocked: false,
      relationshipStatus: 'none',
      actionLabel: 'Follow',
      blockStatus: 'none',
      canFollow: false,
      canMessage: false,
      canCall: false,
      canViewProfile: false,
      isOwner: false,
      isHost: false,
      hasJoined: false,
      canJoin: false,
      canWatch: false,
      canComment: false,
      canReact: false,
      canEnd: false,
      canReport: false,
      isCohost: false,
      canRequestCohost: false,
      canInviteCohost: false,
      cohostStatus: null,
      cohostWorkflow: null,
    );
  }

  factory LiveViewerState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LiveViewerState.initial();

    final rawWorkflow = json['cohost_workflow'];

    return LiveViewerState(
      targetUser: json['target_user']?.toString(),
      isSelf: json['is_self'] == true,
      isFollowing: json['is_following'] == true,
      isFollowedBy: json['is_followed_by'] == true,
      isFriend: json['is_friend'] == true,
      isBlockedByMe: json['is_blocked_by_me'] == true,
      hasBlockedMe: json['has_blocked_me'] == true,
      isBlocked: json['is_blocked'] == true,
      relationshipStatus: json['relationship_status']?.toString() ?? 'none',
      actionLabel: json['action_label']?.toString() ?? 'Follow',
      blockStatus: json['block_status']?.toString() ?? 'none',
      canFollow: json['can_follow'] == true,
      canMessage: json['can_message'] == true,
      canCall: json['can_call'] == true,
      canViewProfile: json['can_view_profile'] == true,
      isOwner: json['is_owner'] == true,
      isHost: json['is_host'] == true,
      hasJoined: json['has_joined'] == true,
      canJoin: json['can_join'] == true,
      canWatch: json['can_watch'] == true,
      canComment: json['can_comment'] == true,
      canReact: json['can_react'] == true,
      canEnd: json['can_end'] == true,
      canReport: json['can_report'] == true,
      isCohost: json['is_cohost'] == true,
      canRequestCohost: json['can_request_cohost'] == true,
      canInviteCohost: json['can_invite_cohost'] == true,
      cohostStatus: json['cohost_status']?.toString(),
      cohostWorkflow: rawWorkflow is Map<Object?, Object?>
          ? LiveCohost.fromJson(asJsonMap(rawWorkflow))
          : null,
    );
  }

  LiveViewerState copyWith({
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    bool? isBlockedByMe,
    bool? hasBlockedMe,
    bool? isBlocked,
    String? relationshipStatus,
    String? actionLabel,
    String? blockStatus,
    bool? canFollow,
    bool? canMessage,
    bool? canCall,
    bool? canViewProfile,
    bool? isOwner,
    bool? isHost,
    bool? hasJoined,
    bool? canJoin,
    bool? canWatch,
    bool? canComment,
    bool? canReact,
    bool? canEnd,
    bool? canReport,
    bool? isCohost,
    bool? canRequestCohost,
    bool? canInviteCohost,
    String? cohostStatus,
    LiveCohost? cohostWorkflow,
    bool clearCohostWorkflow = false,
  }) {
    return LiveViewerState(
      targetUser: targetUser ?? this.targetUser,
      isSelf: isSelf ?? this.isSelf,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isFriend: isFriend ?? this.isFriend,
      isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
      hasBlockedMe: hasBlockedMe ?? this.hasBlockedMe,
      isBlocked: isBlocked ?? this.isBlocked,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      actionLabel: actionLabel ?? this.actionLabel,
      blockStatus: blockStatus ?? this.blockStatus,
      canFollow: canFollow ?? this.canFollow,
      canMessage: canMessage ?? this.canMessage,
      canCall: canCall ?? this.canCall,
      canViewProfile: canViewProfile ?? this.canViewProfile,
      isOwner: isOwner ?? this.isOwner,
      isHost: isHost ?? this.isHost,
      hasJoined: hasJoined ?? this.hasJoined,
      canJoin: canJoin ?? this.canJoin,
      canWatch: canWatch ?? this.canWatch,
      canComment: canComment ?? this.canComment,
      canReact: canReact ?? this.canReact,
      canEnd: canEnd ?? this.canEnd,
      canReport: canReport ?? this.canReport,
      isCohost: isCohost ?? this.isCohost,
      canRequestCohost: canRequestCohost ?? this.canRequestCohost,
      canInviteCohost: canInviteCohost ?? this.canInviteCohost,
      cohostStatus: cohostStatus ?? this.cohostStatus,
      cohostWorkflow: clearCohostWorkflow
          ? null
          : cohostWorkflow ?? this.cohostWorkflow,
    );
  }

  @override
  List<Object?> get props => [
    targetUser,
    isSelf,
    isFollowing,
    isFollowedBy,
    isFriend,
    isBlockedByMe,
    hasBlockedMe,
    isBlocked,
    relationshipStatus,
    actionLabel,
    blockStatus,
    canFollow,
    canMessage,
    canCall,
    canViewProfile,
    isOwner,
    isHost,
    hasJoined,
    canJoin,
    canWatch,
    canComment,
    canReact,
    canEnd,
    canReport,
    isCohost,
    canRequestCohost,
    canInviteCohost,
    cohostStatus,
    cohostWorkflow,
  ];
}
