import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortsState {
  final List<Short> shorts;
  final String? cursor;
  final bool hasMore;
  final bool isLoading;
  final int currentIndex;

  const ShortsState({
    required this.shorts,
    this.cursor,
    this.hasMore = true,
    this.isLoading = false,
    this.currentIndex = 0,
  });

  ShortsState copyWith({
    List<Short>? shorts,
    String? cursor,
    bool? hasMore,
    bool? isLoading,
    int? currentIndex,
  }) {
    return ShortsState(
      shorts: shorts ?? this.shorts,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
