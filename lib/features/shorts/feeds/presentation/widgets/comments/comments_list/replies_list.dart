import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/comment_main_row.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepliesList extends ConsumerWidget {
  final String rootCommentId;

  const RepliesList({super.key, required this.rootCommentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(repliesControllerProvider(rootCommentId));
    final controller = ref.read(
      repliesControllerProvider(rootCommentId).notifier,
    );

    if (state.isLoading && state.replies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!state.isLoading && state.replies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ...state.replies.map((reply) {
          final isLikePending = state.pendingLikeIds.contains(reply.id.value);
          final isDeletePending = state.pendingDeleteIds.contains(
            reply.id.value,
          );

          return ReplyTile(
            key: ValueKey(reply.id.value),
            reply: reply,
            isLikePending: isLikePending,
            isDeletePending: isDeletePending,
            onToggleLike: () {
              controller.toggleCommentLike(reply.id.value);
            },
            onDelete: reply.canDelete || reply.isOwner
                ? () {
                    controller.deleteComment(reply.id.value);
                  }
                : null,
          );
        }),
        if (state.hasMore)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: state.isLoadingMore
                  ? null
                  : controller.loadMoreReplies,
              child: state.isLoadingMore
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('View more replies'),
            ),
          ),
      ],
    );
  }
}

class ReplyTile extends StatelessWidget {
  final ShortComment reply;
  final VoidCallback? onToggleLike;
  final VoidCallback? onDelete;
  final bool isLikePending;
  final bool isDeletePending;

  const ReplyTile({
    super.key,
    required this.reply,
    this.onToggleLike,
    this.onDelete,
    this.isLikePending = false,
    this.isDeletePending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CommentMainRow(
        comment: reply,
        isLikePending: isLikePending,
        isDeletePending: isDeletePending,
        onToggleLike: onToggleLike,
        onDelete: onDelete,
        onReplyTap: () {},
      ),
    );
  }
}
