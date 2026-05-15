import 'package:africaonlinestores/features/shorts/shared/data/models/short_comment_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';

class CommentMapper {
  static ShortComment toDomain(ShortCommentModel model) {
    return ShortComment(
      id: CommentId(model.id),
      shortId: ShortId(model.shortId),
      userId: model.userId,
      displayName: model.displayName,
      avatar: model.avatar,
      comment: model.comment,
      parentId: model.parentId,
      rootId: model.rootId,
      replyCount: model.replyCount,
      likeCount: model.likeCount,
      isLiked: model.isLiked,
      isOwner: model.isOwner,
      canDelete: model.canDelete,
      isDeleted: model.isDeleted,
      createdAt: model.createdAt,
    );
  }
}
