import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

const Object _unset = Object();

class ShortDetailState extends Equatable {
  final List<Short> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentIndex;
  final Set<String> pendingLikeIds;
  final Set<String> pendingFollowUserIds;
  final Set<String> pendingSaveIds;
  final String? errorMessage;

  const ShortDetailState({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    required this.isLoadingMore,
    required this.currentIndex,
    required this.pendingLikeIds,
    required this.pendingFollowUserIds,
    required this.pendingSaveIds,
    required this.errorMessage,
  });

  factory ShortDetailState.initial({
    required List<Short> items,
    required String? nextCursor,
    required bool hasMore,
    required int currentIndex,
  }) {
    return ShortDetailState(
      items: List.unmodifiable(items),
      nextCursor: nextCursor,
      hasMore: hasMore,
      isLoadingMore: false,
      currentIndex: currentIndex,
      pendingLikeIds: const {},
      pendingFollowUserIds: const {},
      pendingSaveIds: const {},
      errorMessage: null,
    );
  }

  ShortDetailState copyWith({
    List<Short>? items,
    Object? nextCursor = _unset,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentIndex,
    Set<String>? pendingLikeIds,
    Set<String>? pendingSaveIds,
    Set<String>? pendingFollowUserIds,
    Object? errorMessage = _unset,
  }) {
    return ShortDetailState(
      items: items ?? this.items,
      nextCursor: nextCursor == _unset
          ? this.nextCursor
          : nextCursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentIndex: currentIndex ?? this.currentIndex,
      pendingLikeIds: pendingLikeIds ?? this.pendingLikeIds,
      pendingSaveIds: pendingLikeIds ?? this.pendingSaveIds,
      pendingFollowUserIds: pendingFollowUserIds ?? this.pendingFollowUserIds,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    items,
    nextCursor,
    hasMore,
    isLoadingMore,
    currentIndex,
    pendingLikeIds,
    pendingSaveIds,
    pendingFollowUserIds,
    errorMessage,
  ];
}

class ShortDetailArgs extends Equatable {
  final List<Short> initialShorts;
  final int initialIndex;
  final String? initialNextCursor;
  final bool initialHasMore;

  const ShortDetailArgs({
    required this.initialShorts,
    required this.initialIndex,
    required this.initialNextCursor,
    required this.initialHasMore,
  });

  @override
  List<Object?> get props => [
    initialShorts,
    initialIndex,
    initialNextCursor,
    initialHasMore,
  ];
}
