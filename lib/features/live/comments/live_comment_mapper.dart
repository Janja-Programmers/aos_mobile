import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_model.dart';

class LiveCommentMapper {
  const LiveCommentMapper._();

  static LiveComment toDomain(LiveCommentModel model) {
    final reply = model.replyTo;
    return LiveComment(
      id: model.id,
      liveId: model.liveId,
      userId: model.userId,
      displayName: model.displayName,
      avatarUrl: _fileUrl(model.avatarUrl),
      isVerified: model.isVerified,
      comment: model.comment,
      messageKind: model.messageKind,
      messageType: model.messageType,
      parentId: model.parentId,
      rootId: model.rootId,
      replyCount: model.replyCount,
      replyTo: reply == null
          ? null
          : LiveCommentReplyContext(
              messageId: reply.messageId,
              userId: reply.userId,
              displayName: reply.displayName,
              avatarUrl: _fileUrl(reply.avatarUrl),
              isVerified: reply.isVerified,
              comment: reply.comment,
            ),
      isDeleted: model.isDeleted,
      createdAt: DateTime.tryParse(model.createdAt) ?? DateTime.now(),
    );
  }

  static String? _fileUrl(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return null;
    final resolved = buildFileUrl(clean);
    return resolved?.trim().isNotEmpty ?? false ? resolved : clean;
  }
}
