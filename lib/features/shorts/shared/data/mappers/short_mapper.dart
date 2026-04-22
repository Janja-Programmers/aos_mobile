import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/enums/short_status.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/value_objects/caption.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short_ad.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short_viewer_state.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/metrics_mapper.dart';

class ShortMapper {
  static Short toDomain(ShortModel model) {
    return Short(
      id: ShortId(model.id),
      playbackUrl: model.playbackUrl,
      thumbnailUrl: model.thumbnailUrl,
      durationSeconds: model.durationSeconds,
      caption: Caption(model.caption),
      hashtags: model.hashtags,
      ownerId: model.ownerId,
      status: ShortStatus.fromString(model.status),
      metrics: MetricsMapper.toDomain(model.metrics),
      ad: model.ad == null
          ? null
          : ShortAd(
              id: model.ad!.id,
              title: model.ad!.title,
              price: model.ad!.price,
              currency: model.ad!.currency,
              thumbnail: model.ad!.thumbnail,
            ),
      postedAt: model.postedAt == null
          ? null
          : DateTime.tryParse(model.postedAt!),
      viewerState: ShortViewerState(
        liked: model.viewerState.liked,
        watched: model.viewerState.watched,
        watchProgress: model.viewerState.watchProgress,
      ),
    );
  }
}
