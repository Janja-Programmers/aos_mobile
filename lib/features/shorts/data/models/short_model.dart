import 'package:africaonlinestores/features/shorts/data/models/short_metrics_model.dart';

class ShortModel {
  final String id;

  final String caption;
  final List<String> hashtags;

  final String? playbackUrl;
  final String? thumbnailUrl;

  final double durationSeconds;

  final ShortMetricsModel metrics;

  final double rankingScore;

  final String? postedOn;

  final bool isReady;
  final bool isProcessing;
  final bool isFailed;

  const ShortModel({
    required this.id,
    required this.caption,
    required this.hashtags,
    required this.playbackUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.metrics,
    required this.rankingScore,
    required this.postedOn,
    required this.isReady,
    required this.isProcessing,
    required this.isFailed,
  });

  factory ShortModel.fromJson(Map<String, dynamic> json) {
    return ShortModel(
      id: json['id'] as String,

      caption: (json['caption'] ?? '') as String,

      hashtags: (json['hashtags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      playbackUrl: json['playback_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,

      durationSeconds: (json['duration_seconds'] ?? 0).toDouble(),

      metrics: ShortMetricsModel.fromJson(json),

      rankingScore: (json['ranking_score'] ?? 0).toDouble(),

      postedOn: json['posted_on'] as String?,

      isReady: json['is_ready'] ?? false,
      isProcessing: json['is_processing'] ?? false,
      isFailed: json['is_failed'] ?? false,
    );
  }
}
