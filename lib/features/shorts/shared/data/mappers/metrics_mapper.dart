import 'package:africaonlinestores/features/shorts/create_short/domain/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_metrics_model.dart';

class MetricsMapper {
  static ShortMetrics toDomain(
    ShortMetricsModel model, {
    bool likedByMe = false,
  }) {
    return ShortMetrics(
      likeCount: model.likes,
      commentCount: model.comments,
      viewCount: model.views,
      likedByMe: likedByMe,
    );
  }
}
