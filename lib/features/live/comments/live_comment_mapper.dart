import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_model.dart';

class LiveCommentMapper {
  const LiveCommentMapper._();

  static LiveComment toDomain(LiveCommentModel model) {
    return LiveComment(
      id: model.id,
      liveId: model.liveId,
      userId: model.userId,
      displayName: model.displayName,
      comment: model.comment,
      messageKind: model.messageKind,
      messageType: model.messageType,
      parentId: model.parentId,
      rootId: model.rootId,
      replyCount: model.replyCount,
      isDeleted: model.isDeleted,
      createdAt: DateTime.tryParse(model.createdAt) ?? DateTime.now(),
    );
  }
}
