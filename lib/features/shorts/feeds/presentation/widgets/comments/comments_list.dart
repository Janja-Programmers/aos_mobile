import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list/comment_tile.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentsList extends ConsumerStatefulWidget {
  final String shortId;

  const CommentsList({super.key, required this.shortId});

  @override
  ConsumerState<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      ref.read(commentsControllerProvider.notifier).init(widget.shortId);
    });
  }

  @override
  void didUpdateWidget(covariant CommentsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shortId != widget.shortId) {
      Future.microtask(() {
        ref.read(commentsControllerProvider.notifier).init(widget.shortId);
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.extentAfter < 240) {
      ref.read(commentsControllerProvider.notifier).loadMore(widget.shortId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsControllerProvider);

    if (state.isLoading && state.comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.isLoading && state.comments.isEmpty) {
      return const Center(child: Text('No comments yet'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: state.comments.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index >= state.comments.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final comment = state.comments[index];
        return CommentTile(key: ValueKey(comment.id.value), comment: comment);
      },
    );
  }
}
