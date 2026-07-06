class LiveComment {
  final String id;
  final String liveId;
  final String userId;
  final String displayName;
  final String comment;
  final String messageKind;
  final String messageType;
  final String? parentId;
  final String? rootId;
  final int replyCount;
  final bool isDeleted;
  final DateTime createdAt;

  const LiveComment({
    required this.id,
    required this.liveId,
    required this.userId,
    required this.displayName,
    required this.comment,
    required this.messageKind,
    required this.messageType,
    required this.parentId,
    required this.rootId,
    required this.replyCount,
    required this.isDeleted,
    required this.createdAt,
  });

  bool get isSystem => messageKind == 'system' || messageType == 'system';

  String get authorLabel {
    if (displayName.trim().isNotEmpty) return displayName.trim();
    if (userId.trim().isNotEmpty) return userId.trim();
    return isSystem ? 'AOS' : 'Viewer';
  }
}
