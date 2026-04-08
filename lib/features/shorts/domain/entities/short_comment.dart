import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

class ShortComment extends Equatable {
  final CommentId id;

  /// The short this comment belongs to
  final ShortId shortId;

  /// User who created the comment
  final String userId;

  /// Actual content
  final String content;

  /// Parent comment (null if top-level)
  final CommentId? parentId;

  /// Root comment for threading (optional but useful)
  final CommentId? rootId;

  /// Number of replies
  final int replyCount;

  /// Soft delete flag
  final bool isDeleted;

  /// Timestamp (ISO string for now)
  final String createdAt;

  const ShortComment({
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

  bool get isReply => parentId != null;

  bool get isTopLevel => parentId == null;

  ShortComment copyWith({String? content, int? replyCount, bool? isDeleted}) {
    return ShortComment(
      id: id,
      shortId: shortId,
      userId: userId,
      content: content ?? this.content,
      parentId: parentId,
      rootId: rootId,
      replyCount: replyCount ?? this.replyCount,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shortId,
    userId,
    content,
    parentId,
    rootId,
    replyCount,
    isDeleted,
    createdAt,
  ];
}
