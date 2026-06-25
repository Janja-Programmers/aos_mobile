import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';

class ShortCommentsPage {
  final List<ShortComment> items;
  final String? nextCursor;
  final bool hasMore;

  const ShortCommentsPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}
