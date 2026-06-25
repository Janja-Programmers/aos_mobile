import 'package:africaonlinestores/features/shorts/shared/data/models/short_metrics_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_metrics.dart';

class MetricsMapper {
  static ShortMetrics toDomain(ShortMetricsModel model) {
    return ShortMetrics(
      likeCount: model.likeCount,
      commentCount: model.commentCount,
      viewCount: model.viewCount,
      shareCount: model.shareCount,
      saveCount: model.saveCount,
      impressionCount: model.impressionCount,
      downloadCount: model.downloadCount,
      repostCount: model.repostCount,
      rankingScore: model.rankingScore,
    );
  }
}
