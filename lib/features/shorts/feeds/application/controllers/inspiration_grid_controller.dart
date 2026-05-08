import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/following/inspiration_grid_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';

class InspirationGridController extends StateNotifier<InspirationGridState> {
  final ShortsRepository repository;

  InspirationGridController(this.repository)
    : super(const InspirationGridState(shorts: []));

  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      shorts: [],
      hasMore: true,
      clearCursor: true,
    );

    try {
      final page = await repository.fetchForYou();

      state = state.copyWith(
        shorts: page.items,
        cursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, isLoadingMore: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await repository.fetchForYou(cursor: state.cursor);

      state = state.copyWith(
        shorts: [...state.shorts, ...page.items],
        cursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}
