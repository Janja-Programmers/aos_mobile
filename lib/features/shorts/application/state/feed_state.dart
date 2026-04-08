import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';

class FeedState extends Equatable {
  final List<Short> items;

  final bool isLoading;
  final bool isLoadingMore;

  final String? nextCursor;
  final bool hasMore;

  final String? error;

  const FeedState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.nextCursor,
    required this.hasMore,
    required this.error,
  });

  factory FeedState.initial() {
    return const FeedState(
      items: [],
      isLoading: false,
      isLoadingMore: false,
      nextCursor: null,
      hasMore: true,
      error: null,
    );
  }

  bool get isEmpty => items.isEmpty;

  FeedState copyWith({
    List<Short>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? nextCursor,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    items,
    isLoading,
    isLoadingMore,
    nextCursor,
    hasMore,
    error,
  ];
}
