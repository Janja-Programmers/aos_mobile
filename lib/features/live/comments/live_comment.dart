class LiveComment {
  final String id;
  final String liveId;
  final String userId;
  final String comment;
  final String? parentId;
  final String? rootId;
  final int replyCount;
  final bool isDeleted;
  final DateTime createdAt;

  const LiveComment({
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
}
