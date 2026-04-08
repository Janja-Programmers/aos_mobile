import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/domain/repository/shorts_repository.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';

import 'package:africaonlinestores/features/shorts/application/metrics/metrics_notifier.dart';
import 'package:africaonlinestores/features/shorts/application/state/feed_state.dart';

class FeedController extends StateNotifier<FeedState> {
  final ShortsRepository _repository;
  final MetricsNotifier _metricsNotifier;

  FeedController({
    required ShortsRepository repository,
    required MetricsNotifier metricsNotifier,
  }) : _repository = repository,
       _metricsNotifier = metricsNotifier,
       super(FeedState.initial());

  // ───────────── INITIAL LOAD ─────────────

  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final page = await _repository.feedForYou();

      _hydrateMetrics(page.items);

      state = state.copyWith(
        items: page.items,
        isLoading: false,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ───────────── LOAD MORE ─────────────

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await _repository.feedForYou(cursor: state.nextCursor);

      _hydrateMetrics(page.items);

      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  // ───────────── METRICS HYDRATION ─────────────

  void _hydrateMetrics(List<Short> shorts) {
    final pairs = shorts.map((s) => (s.id, s.metrics)).toList();

    _metricsNotifier.hydrateFromFeed(pairs);
  }

  // ───────────── REFRESH ─────────────

  Future<void> refresh() async {
    state = FeedState.initial();
    await loadInitial();
  }
}
