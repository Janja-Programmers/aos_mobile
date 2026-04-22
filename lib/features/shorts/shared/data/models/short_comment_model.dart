class ShortCommentModel {
  final String id;
  final String shortId;
  final String userId;
  final String comment;
  final String? parentId;
  final String? rootId;
  final int replyCount;
  final bool isDeleted;
  final String createdAt;

  const ShortCommentModel({
    required this.id,
    required this.shortId,
    required this.userId,
    required this.comment,
    required this.parentId,
    required this.rootId,
    required this.replyCount,
    required this.isDeleted,
    required this.createdAt,
  });

  factory ShortCommentModel.fromJson(Map<String, dynamic> json) {
    return ShortCommentModel(
      id: json['id'],
      shortId: json['short_id'],
      userId: json['user_id'],
      comment: json['comment'],
      parentId: json['parent_id'],
      rootId: json['root_id'],
      replyCount: json['reply_count'] ?? 0,
      isDeleted: json['is_deleted'] ?? false,
      createdAt: json['created_at'],
    );
  }
}
