import 'package:africaonlinestores/features/shorts/domain/short_comment.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

import 'package:africaonlinestores/features/shorts/data/models/short_comment_model.dart';

class CommentMapper {
  const CommentMapper._();

  static ShortComment toDomain(ShortCommentModel model) {
    return ShortComment(
      id: CommentId(model.id),
      shortId: ShortId(model.shortId),
      userId: model.userId,
      comment: model.comment,
      parentId: model.parentId != null ? CommentId(model.parentId!) : null,
      rootId: model.rootId != null ? CommentId(model.rootId!) : null,
      replyCount: model.replyCount,
      isDeleted: model.isDeleted,
      createdAt: model.createdAt,
    );
  }
}
