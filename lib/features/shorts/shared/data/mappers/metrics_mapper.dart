import 'package:africaonlinestores/features/shorts/shared/domain/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_metrics_model.dart';

class MetricsMapper {
  static ShortMetrics toDomain(
    ShortMetricsModel model, {
    bool likedByMe = false,
  }) {
    return ShortMetrics(
      likeCount: model.likeCount,
      commentCount: model.commentCount,
      viewCount: model.viewCount,
      likedByMe: likedByMe,
      shareCount: model.shareCount,
      impressionCount: model.impressionCount,
      rankingScore: model.rankingScore,
    );
  }
}
