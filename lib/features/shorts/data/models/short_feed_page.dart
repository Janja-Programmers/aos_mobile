import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/short.dart';

class ShortFeedPage extends Equatable {
  final List<Short> items;

  /// Cursor for next page
  final String? nextCursor;

  /// Whether more data exists
  final bool hasMore;

  const ShortFeedPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}
