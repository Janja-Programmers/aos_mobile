import 'package:equatable/equatable.dart';

class LiveViewerState extends Equatable {
  final String? targetUser;

  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;

  final String relationshipStatus;
  final String actionLabel;

  final bool isOwner;
  final bool isHost;
  final bool hasJoined;

  final bool canJoin;
  final bool canWatch;
  final bool canComment;
  final bool canReact;
  final bool canEnd;
  final bool canReport;

  const LiveViewerState({
    required this.targetUser,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
    required this.isOwner,
    required this.isHost,
    required this.hasJoined,
    required this.canJoin,
    required this.canWatch,
    required this.canComment,
    required this.canReact,
    required this.canEnd,
    required this.canReport,
  });

  factory LiveViewerState.initial() {
    return const LiveViewerState(
      targetUser: null,
      isSelf: false,
      isFollowing: false,
      isFollowedBy: false,
      isFriend: false,
      relationshipStatus: 'none',
      actionLabel: 'Follow',
      isOwner: false,
      isHost: false,
      hasJoined: false,
      canJoin: true,
      canWatch: true,
      canComment: false,
      canReact: false,
      canEnd: false,
      canReport: true,
    );
  }

  factory LiveViewerState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LiveViewerState.initial();

    return LiveViewerState(
      targetUser: json['target_user']?.toString(),
      isSelf: json['is_self'] == true,
      isFollowing: json['is_following'] == true,
      isFollowedBy: json['is_followed_by'] == true,
      isFriend: json['is_friend'] == true,
      relationshipStatus: json['relationship_status']?.toString() ?? 'none',
      actionLabel: json['action_label']?.toString() ?? 'Follow',
      isOwner: json['is_owner'] == true,
      isHost: json['is_host'] == true,
      hasJoined: json['has_joined'] == true,
      canJoin: json['can_join'] == true,
      canWatch: json['can_watch'] == true,
      canComment: json['can_comment'] == true,
      canReact: json['can_react'] == true,
      canEnd: json['can_end'] == true,
      canReport: json['can_report'] == true,
    );
  }

  LiveViewerState copyWith({
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    String? relationshipStatus,
    String? actionLabel,
    bool? isOwner,
    bool? isHost,
    bool? hasJoined,
    bool? canJoin,
    bool? canWatch,
    bool? canComment,
    bool? canReact,
    bool? canEnd,
    bool? canReport,
  }) {
    return LiveViewerState(
      targetUser: targetUser ?? this.targetUser,
      isSelf: isSelf ?? this.isSelf,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isFriend: isFriend ?? this.isFriend,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      actionLabel: actionLabel ?? this.actionLabel,
      isOwner: isOwner ?? this.isOwner,
      isHost: isHost ?? this.isHost,
      hasJoined: hasJoined ?? this.hasJoined,
      canJoin: canJoin ?? this.canJoin,
      canWatch: canWatch ?? this.canWatch,
      canComment: canComment ?? this.canComment,
      canReact: canReact ?? this.canReact,
      canEnd: canEnd ?? this.canEnd,
      canReport: canReport ?? this.canReport,
    );
  }

  @override
  List<Object?> get props => [
    targetUser,
    isSelf,
    isFollowing,
    isFollowedBy,
    isFriend,
    relationshipStatus,
    actionLabel,
    isOwner,
    isHost,
    hasJoined,
    canJoin,
    canWatch,
    canComment,
    canReact,
    canEnd,
    canReport,
  ];
}
