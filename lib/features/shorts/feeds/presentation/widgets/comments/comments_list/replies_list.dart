import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/providers/feed_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/short_comment.dart';

class RepliesList extends ConsumerWidget {
  final String rootCommentId;

  const RepliesList({super.key, required this.rootCommentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(repliesControllerProvider(rootCommentId));

    if (state.isLoading && state.replies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Column(
      children: state.replies.map((reply) => ReplyTile(reply: reply)).toList(),
    );
  }
}

class ReplyTile extends StatelessWidget {
  final ShortComment reply;

  const ReplyTile({super.key, required this.reply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 14),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${reply.userId}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(reply.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
