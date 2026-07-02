import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/comment_main_row.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/replies_list.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/reply_input.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentTile extends ConsumerStatefulWidget {
  final ShortComment comment;

  const CommentTile({super.key, required this.comment});

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  bool _showReplies = false;
  bool _isReplying = false;

  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final comment = widget.comment;
    final text = _replyController.text.trim();

    if (text.isEmpty) return;

    await ref
        .read(repliesControllerProvider(comment.id.value).notifier)
        .reply(
          rootCommentId: comment.id.value,
          parentCommentId: comment.id.value,
          shortId: comment.shortId.value,
          content: text,
        );

    _replyController.clear();

    if (!mounted) return;

    setState(() {
      _isReplying = false;
      _showReplies = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    final commentsState = ref.watch(commentsControllerProvider);
    final commentsController = ref.read(commentsControllerProvider.notifier);

    final isLikePending = commentsState.pendingLikeIds.contains(
      comment.id.value,
    );

    final isDeletePending = commentsState.pendingDeleteIds.contains(
      comment.id.value,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentMainRow(
            comment: comment,
            isLikePending: isLikePending,
            isDeletePending: isDeletePending,
            onReplyTap: () {
              setState(() => _isReplying = !_isReplying);
            },
            onToggleLike: () {
              commentsController.toggleCommentLike(comment.id.value);
            },
            onDelete: comment.canDelete || comment.isOwner
                ? () {
                    commentsController.deleteComment(comment.id.value);
                  }
                : null,
          ),

          if (_isReplying)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 10),
              child: ReplyInput(
                controller: _replyController,
                onSend: _sendReply,
              ),
            ),

          if (comment.replyCount > 0)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _showReplies = !_showReplies);

                if (_showReplies) {
                  ref
                      .read(
                        repliesControllerProvider(comment.id.value).notifier,
                      )
                      .init(comment.id.value);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 48, top: 8),
                child: Text(
                  _showReplies
                      ? 'Hide replies'
                      : 'View replies (${comment.replyCount})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (_showReplies)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: RepliesList(rootCommentId: comment.id.value),
            ),
        ],
      ),
    );
  }
}
