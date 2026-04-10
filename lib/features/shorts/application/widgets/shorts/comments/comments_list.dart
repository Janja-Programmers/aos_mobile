import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/application/widgets/shorts/comments/comments_list/comment_tile.dart';
import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';

class CommentsList extends ConsumerStatefulWidget {
  final String shortId;

  const CommentsList({super.key, required this.shortId});

  @override
  ConsumerState<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(commentsControllerProvider.notifier).init(widget.shortId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsControllerProvider);

    if (state.isLoading && state.comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.isLoading && state.comments.isEmpty) {
      return const Center(child: Text("No comments yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: state.comments.length,
      itemBuilder: (_, index) {
        return CommentTile(comment: state.comments[index]);
      },
    );
  }
}
