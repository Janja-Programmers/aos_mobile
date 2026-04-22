import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';

class ShortGridState {
  final List<ShortModel> shorts;

  final bool isLoading;
  final bool hasMore;
  final String? cursor;

  const ShortGridState({
    required this.shorts,
    this.isLoading = false,
    this.hasMore = true,
    this.cursor,
  });

  ShortGridState copyWith({
    List<ShortModel>? shorts,
    bool? isLoading,
    bool? hasMore,
    String? cursor,
  }) {
    return ShortGridState(
      shorts: shorts ?? this.shorts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
    );
  }
}
