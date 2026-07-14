class ShortViewerStateModel {
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

  const ShortViewerStateModel({
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

  factory ShortViewerStateModel.initial() {
    return const ShortViewerStateModel(
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

  factory ShortViewerStateModel.fromJson(Map<String, dynamic> json) {
    return ShortViewerStateModel(
      liked: _toBool(json['is_liked']),
      watched: _toBool(json['watched']),
      watchProgress: _toDouble(json['watch_progress']),

      isSaved: _toBool(json['is_saved'] ?? json['saved']),
      isReposted: _toBool(json['is_reposted'] ?? json['reposted']),
      canRepost: _toBool(json['can_repost']),

      isOwner: _toBool(json['is_owner']),
      canEdit: _toBool(json['can_edit']),
      canDelete: _toBool(json['can_delete']),
      canReport: _toBool(json['can_report']),

      targetUser: json['target_user']?.toString(),
      isSelf: _toBool(json['is_self']),

      isFollowing: _toBool(json['is_following']),
      isFollowedBy: _toBool(json['is_followed_by']),
      isFriend: _toBool(json['is_friend']),

      relationshipStatus: json['relationship_status']?.toString() ?? 'none',
      actionLabel: json['action_label']?.toString() ?? 'Follow',
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value?.toString().trim().toLowerCase();

    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
