import 'package:africaonlinestores/features/shorts/shared/domain/short_comment.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_comment_model.dart';

class CommentMapper {
  static ShortComment toDomain(ShortCommentModel model) {
    return ShortComment(
      id: CommentId(model.id),
      shortId: ShortId(model.shortId),
      userId: model.userId,
      comment: model.comment,
      parentId: model.parentId == null ? null : CommentId(model.parentId!),
      rootId: model.rootId == null ? null : CommentId(model.rootId!),
      replyCount: model.replyCount,
      isDeleted: model.isDeleted,
      createdAt: model.createdAt,
    );
  }
}
