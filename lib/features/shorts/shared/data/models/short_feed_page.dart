import 'package:equatable/equatable.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';

class ShortFeedPage extends Equatable {
  final List<ShortModel> items;
  final String? nextCursor;
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
