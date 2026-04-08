import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/caption.dart';
import 'package:africaonlinestores/features/shorts/domain/enums/short_status.dart';

import 'package:africaonlinestores/features/shorts/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/data/mappers/metrics_mapper.dart';

class ShortMapper {
  const ShortMapper._();

  static Short toDomain(ShortModel model) {
    final status = _resolveStatus(model);

    return Short(
      id: ShortId(model.id),

      playbackUrl: model.playbackUrl ?? '',
      thumbnailUrl: model.thumbnailUrl ?? '',

      caption: Caption(model.caption),

      hashtags: model.hashtags,

      ownerId: '',

      status: status,

      metrics: MetricsMapper.toDomain(model.metrics),

      durationSeconds: model.durationSeconds.toInt(),
    );
  }

  /// 🔥 Core lifecycle logic
  static ShortStatus _resolveStatus(ShortModel model) {
    // If backend later provides explicit status → use it
    // For now infer safely

    if (model.playbackUrl != null && model.playbackUrl!.isNotEmpty) {
      return ShortStatus.ready;
    }

    // Could refine later with backend status field
    return ShortStatus.processing;
  }
}
