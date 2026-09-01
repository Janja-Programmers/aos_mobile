import 'package:africaonlinestores/features/live/comments/live_comment.dart';

class LiveCommentsPage {
  const LiveCommentsPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<LiveComment> items;
  final String? nextCursor;
  final bool hasMore;
}
