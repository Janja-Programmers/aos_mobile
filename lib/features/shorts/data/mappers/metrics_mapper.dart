import 'package:africaonlinestores/features/shorts/data/models/short_metrics_model.dart';
import 'package:africaonlinestores/features/shorts/domain/short_metrics.dart';

class MetricsMapper {
  const MetricsMapper._();

  static ShortMetrics toDomain(ShortMetricsModel model) {
    return ShortMetrics(
      likeCount: model.likeCount,
      commentCount: model.commentCount,
      viewCount: model.viewCount,
      likedByMe: false,
    );
  }
}
