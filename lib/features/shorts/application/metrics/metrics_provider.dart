import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/application/metrics/metrics_state.dart';
import 'package:africaonlinestores/features/shorts/application/metrics/metrics_notifier.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

// Root store
final metricsNotifierProvider =
    StateNotifierProvider<MetricsNotifier, MetricsState>(
      (ref) => MetricsNotifier(),
    );

// Fine-grained selector per short
final shortMetricsProvider = Provider.family<ShortMetrics?, ShortId>((
  ref,
  shortId,
) {
  final state = ref.watch(metricsNotifierProvider);
  return state.get(shortId);
});

// Even finer: select specific fields to avoid rebuilds
final shortLikedProvider = Provider.family<bool, ShortId>((ref, shortId) {
  final metrics = ref.watch(
    metricsNotifierProvider.select((s) => s.get(shortId)),
  );
  return metrics?.likedByMe ?? false;
});

final shortLikeCountProvider = Provider.family<int, ShortId>((ref, shortId) {
  final metrics = ref.watch(
    metricsNotifierProvider.select((s) => s.get(shortId)),
  );
  return metrics?.likeCount ?? 0;
});
