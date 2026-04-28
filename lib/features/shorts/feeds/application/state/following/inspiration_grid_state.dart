import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class InspirationGridState {
  final List<Short> shorts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? cursor;

  const InspirationGridState({
    required this.shorts,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.cursor,
  });

  InspirationGridState copyWith({
    List<Short>? shorts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? cursor,
    bool clearCursor = false,
  }) {
    return InspirationGridState(
      shorts: shorts ?? this.shorts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      cursor: clearCursor ? null : cursor ?? this.cursor,
    );
  }
}
