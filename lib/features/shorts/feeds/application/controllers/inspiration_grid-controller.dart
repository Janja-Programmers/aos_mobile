import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/following/inspiration_grid_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class InspirationGridController extends StateNotifier<InspirationGridState> {
  final ShortsFeedApi feedApi;

  InspirationGridController(this.feedApi)
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

    final res = await feedApi.fetchForYou();

    res.fold(
      (_) {
        state = state.copyWith(isLoading: false, isLoadingMore: false);
      },
      (page) {
        state = state.copyWith(
          shorts: page.items,
          cursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoading: false,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final res = await feedApi.fetchForYou(cursor: state.cursor);

    res.fold(
      (_) {
        state = state.copyWith(isLoadingMore: false);
      },
      (page) {
        state = state.copyWith(
          shorts: [...state.shorts, ...page.items],
          cursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
    );
  }
}
