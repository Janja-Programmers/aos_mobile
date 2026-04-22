import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_grid_state.dart';

class ShortGridController extends StateNotifier<ShortGridState> {
  final ShortsFeedApi feedApi;

  ShortGridController(this.feedApi) : super(const ShortGridState(shorts: []));

  bool _isLoadingMore = false;

  /// INITIAL LOAD

  Future<void> loadInitial({String? query}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, shorts: [], cursor: null);

    final res = await feedApi.fetchFollowingGrid(query: query);

    res.fold(
      (err) {
        state = state.copyWith(isLoading: false);
      },
      (page) {
        state = state.copyWith(
          shorts: page.items,

          cursor: page.nextCursor,

          hasMore: page.hasMore,

          isLoading: false,
        );
      },
    );
  }

  /// PAGINATION

  Future<void> loadMore({String? query}) async {
    if (_isLoadingMore) return;

    if (!state.hasMore) return;

    _isLoadingMore = true;

    final res = await feedApi.fetchFollowingGrid(cursor: state.cursor);

    res.fold(
      (err) {
        appLogger.e("❌ GRID LOAD MORE FAILED", error: err);
      },
      (page) {
        state = state.copyWith(
          shorts: [...state.shorts, ...page.items],

          cursor: page.nextCursor,

          hasMore: page.hasMore,
        );
      },
    );

    _isLoadingMore = false;
  }
}
