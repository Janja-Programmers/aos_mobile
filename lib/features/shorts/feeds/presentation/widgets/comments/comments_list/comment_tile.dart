import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/comment_main_row.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/replies_list.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/reply_input.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_comment.dart';

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

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 MAIN COMMENT
          CommentMainRow(
            comment: comment,
            onReplyTap: () {
              setState(() => _isReplying = !_isReplying);
            },
          ),

          const SizedBox(height: 6),

          // 🔥 INLINE REPLY INPUT
          if (_isReplying)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 6),
              child: ReplyInput(
                controller: _replyController,
                onSend: () async {
                  final text = _replyController.text.trim();
                  if (text.isEmpty) return;

                  await ref
                      .read(
                        repliesControllerProvider(comment.id.value).notifier,
                      )
                      .reply(
                        rootCommentId: comment.id.value,
                        parentCommentId: comment.id.value,
                        shortId: comment.shortId.value,
                        content: text,
                      );

                  _replyController.clear();
                  setState(() {
                    _isReplying = false;
                    _showReplies = true;
                  });
                },
              ),
            ),

          // 🔥 VIEW REPLIES BUTTON
          if (comment.replyCount > 0)
            GestureDetector(
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
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  _showReplies
                      ? "Hide replies"
                      : "View replies (${comment.replyCount})",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
            ),

          // 🔥 REPLIES
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
