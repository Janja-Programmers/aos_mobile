class ShortCommentModel {
  final String id;
  final String shortId;
  final String userId;
  final String content;

  final String? parentId;
  final String? rootId;

  final int replyCount;
  final bool isDeleted;

  final String createdAt;

  const ShortCommentModel({
    required this.id,
    required this.shortId,
    required this.userId,
    required this.content,
    required this.parentId,
    required this.rootId,
    required this.replyCount,
    required this.isDeleted,
    required this.createdAt,
  });

  factory ShortCommentModel.fromJson(Map<String, dynamic> json) {
    return ShortCommentModel(
      id: json['id'] as String,
      shortId: json['short_id'] as String,
      userId: json['user'] as String,
      content: (json['content'] ?? '') as String,
      parentId: json['parent_comment'] as String?,
      rootId: json['root_comment'] as String?,
      replyCount: (json['reply_count'] ?? 0) as int,
      isDeleted: (json['status'] == 'deleted'),
      createdAt: json['creation'] as String,
    );
  }
}
