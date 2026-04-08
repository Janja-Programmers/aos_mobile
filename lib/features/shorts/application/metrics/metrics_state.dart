import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

class MetricsState extends Equatable {
  final Map<ShortId, ShortMetrics> items;

  const MetricsState({required this.items});

  factory MetricsState.initial() {
    return const MetricsState(items: {});
  }

  ShortMetrics? get(ShortId id) => items[id];

  MetricsState upsert(ShortId id, ShortMetrics metrics) {
    final next = Map<ShortId, ShortMetrics>.from(items);
    next[id] = metrics;
    return MetricsState(items: next);
  }

  @override
  List<Object?> get props => [items];
}
