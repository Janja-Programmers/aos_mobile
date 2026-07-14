import 'package:equatable/equatable.dart';

class ShortViewerState extends Equatable {
  final bool liked;
  final bool watched;
  final double watchProgress;

  final bool isSaved;
  final bool isReposted;
  final bool canRepost;

  final bool isOwner;
  final bool canEdit;
  final bool canDelete;
  final bool canReport;

  final String? targetUser;
  final bool isSelf;

  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;

  final String relationshipStatus;
  final String actionLabel;

  const ShortViewerState({
    required this.liked,
    required this.watched,
    required this.watchProgress,
    required this.isSaved,
    required this.isReposted,
    required this.canRepost,
    required this.isOwner,
    required this.canEdit,
    required this.canDelete,
    required this.canReport,
    required this.targetUser,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
  });

  factory ShortViewerState.initial() {
    return const ShortViewerState(
      liked: false,
      watched: false,
      watchProgress: 0,
      isSaved: false,
      isReposted: false,
      canRepost: false,
      isOwner: false,
      canEdit: false,
      canDelete: false,
      canReport: true,
      targetUser: null,
      isSelf: false,
      isFollowing: false,
      isFollowedBy: false,
      isFriend: false,
      relationshipStatus: 'none',
      actionLabel: 'Follow',
    );
  }

  ShortViewerState copyWith({
    bool? liked,
    bool? watched,
    double? watchProgress,
    bool? isSaved,
    bool? isReposted,
    bool? canRepost,
    bool? isOwner,
    bool? canEdit,
    bool? canDelete,
    bool? canReport,
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    String? relationshipStatus,
    String? actionLabel,
  }) {
    return ShortViewerState(
      liked: liked ?? this.liked,
      watched: watched ?? this.watched,
      watchProgress: watchProgress ?? this.watchProgress,
      isSaved: isSaved ?? this.isSaved,
      isReposted: isReposted ?? this.isReposted,
      canRepost: canRepost ?? this.canRepost,
      isOwner: isOwner ?? this.isOwner,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      canReport: canReport ?? this.canReport,
      targetUser: targetUser ?? this.targetUser,
      isSelf: isSelf ?? this.isSelf,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isFriend: isFriend ?? this.isFriend,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  @override
  List<Object?> get props => [
    liked,
    watched,
    watchProgress,
    isSaved,
    isReposted,
    canRepost,
    isOwner,
    canEdit,
    canDelete,
    canReport,
    targetUser,
    isSelf,
    isFollowing,
    isFollowedBy,
    isFriend,
    relationshipStatus,
    actionLabel,
  ];
}
