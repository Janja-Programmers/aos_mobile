class LiveCommentModel {
  final String id;
  final String liveId;
  final String userId;
  final String comment;
  final String? parentId;
  final String? rootId;
  final int replyCount;
  final bool isDeleted;
  final String createdAt;

  const LiveCommentModel({
    required this.id,
    required this.liveId,
    required this.userId,
    required this.comment,
    required this.parentId,
    required this.rootId,
    required this.replyCount,
    required this.isDeleted,
    required this.createdAt,
  });

  factory LiveCommentModel.fromJson(Map<String, dynamic> json) {
    return LiveCommentModel(
      id: json['id']?.toString() ?? json['name']?.toString() ?? '',
      liveId:
          json['live_id']?.toString() ?? json['live_stream']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['user']?.toString() ?? '',
      comment: json['comment']?.toString() ?? json['content']?.toString() ?? '',
      parentId:
          json['parent_id']?.toString() ?? json['parent_comment']?.toString(),
      rootId: json['root_id']?.toString() ?? json['root_comment']?.toString(),
      replyCount: int.tryParse(json['reply_count']?.toString() ?? '0') ?? 0,
      isDeleted:
          json['is_deleted'] == true ||
          json['is_deleted'] == 1 ||
          json['is_deleted']?.toString() == '1',
      createdAt:
          json['created_at']?.toString() ??
          json['creation']?.toString() ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'live_id': liveId,
      'user_id': userId,
      'comment': comment,
      'parent_id': parentId,
      'root_id': rootId,
      'reply_count': replyCount,
      'is_deleted': isDeleted,
      'created_at': createdAt,
    };
  }
}
