import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/application/metrics/metrics_state.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

class MetricsNotifier extends StateNotifier<MetricsState> {
  MetricsNotifier() : super(MetricsState.initial());

  // ───────────── INIT / SYNC ─────────────

  void setMetrics({required ShortId shortId, required ShortMetrics metrics}) {
    state = state.upsert(shortId, metrics);
  }

  // ───────────── OPTIMISTIC LIKE ─────────────

  void toggleLikeOptimistic(ShortId shortId) {
    final current = state.get(shortId);
    if (current == null) return;

    final isLiked = current.likedByMe;

    final updated = current.copyWith(
      likedByMe: !isLiked,
      likeCount: isLiked
          ? (current.likeCount - 1).clamp(0, 1 << 31)
          : current.likeCount + 1,
    );

    state = state.upsert(shortId, updated);
  }

  // ───────────── SERVER RECONCILIATION ─────────────

  void applyServerMetrics({
    required ShortId shortId,
    required ShortMetrics metrics,
  }) {
    state = state.upsert(shortId, metrics);
  }

  // ───────────── COMMENT COUNT UPDATE ─────────────

  void incrementCommentCount(ShortId shortId) {
    final current = state.get(shortId);
    if (current == null) return;

    final updated = current.copyWith(commentCount: current.commentCount + 1);

    state = state.upsert(shortId, updated);
  }

  // ───────────── BULK SYNC (FROM FEED) ─────────────

  void hydrateFromFeed(List<(ShortId, ShortMetrics)> pairs) {
    final next = Map<ShortId, ShortMetrics>.from(state.items);

    for (final (id, metrics) in pairs) {
      next[id] = metrics;
    }

    state = MetricsState(items: next);
  }
}
