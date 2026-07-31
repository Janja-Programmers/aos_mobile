import 'package:africaonlinestores/features/shorts/shared/data/mappers/metrics_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_ad_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_creator_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_view_state_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/short_status.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/caption.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';

class ShortMapper {
  static Short toDomain(ShortModel model) {
    return Short(
      id: ShortId(model.id),
      playbackUrl: model.playbackUrl,
      processedFileUrl: model.processedFileUrl,
      thumbnailUrl: model.thumbnailUrl,
      durationSeconds: model.durationSeconds,
      contentMode: model.contentMode,
      caption: Caption(model.caption),
      hashtags: model.hashtags,
      status: ShortStatus.fromString(model.status),
      visibilityStatus: model.visibilityStatus,
      audience: model.audience,
      allowComments: model.allowComments,
      allowDownloads: model.allowDownloads,
      isReady: model.isReady,
      isProcessingFlag: model.isProcessing,
      isFailedFlag: model.isFailed,
      audioMixStatus: model.audioMixStatus,
      audioMixError: model.audioMixError,
      creator: ShortCreatorMapper.toDomain(model.creator),
      metrics: MetricsMapper.toDomain(model.metrics),
      ad: model.ad == null ? null : ShortAdMapper.toDomain(model.ad!),
      sound: model.sound,
      postedAt: model.postedAt == null || model.postedAt!.trim().isEmpty
          ? null
          : DateTime.tryParse(model.postedAt!),
      viewerState: ShortViewerStateMapper.toDomain(model.viewerState),
    );
  }
}
