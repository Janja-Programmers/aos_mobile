import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';

class ShortGridPage {
  final List<ShortModel> items;

  final String? nextCursor;

  final bool hasMore;

  const ShortGridPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}
