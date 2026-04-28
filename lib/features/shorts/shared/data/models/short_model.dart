import 'package:africaonlinestores/features/shorts/shared/data/models/short_ad_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_metrics_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_viewer_state_model.dart';

class ShortModel {
  final String id;

  final String playbackUrl;
  final String thumbnailUrl;
  final int durationSeconds;

  final String caption;
  final List<String> hashtags;

  final String ownerId;

  final String? status;

  final ShortMetricsModel metrics;

  final ShortAdModel? ad;

  final String? postedAt;

  final ShortViewerStateModel viewerState;

  const ShortModel({
    required this.id,
    required this.playbackUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.caption,
    required this.hashtags,
    required this.ownerId,
    this.status,
    required this.metrics,
    required this.viewerState,
    this.ad,
    this.postedAt,
  });

  factory ShortModel.fromJson(Map<String, dynamic> json) {
    return ShortModel(
      id: json['id'] ?? '',

      playbackUrl: json['playback_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',

      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,

      caption: json['caption'] ?? '',

      hashtags: List<String>.from(json['hashtags'] ?? []),

      ownerId: json['seller']?['id'] ?? '',

      status: json['status'] as String?,

      metrics: ShortMetricsModel.fromJson(json),

      ad: _parseAd(json['ad']),

      postedAt: json['posted_on'] as String?,

      viewerState: ShortViewerStateModel.fromJson(
        json['viewer_state'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  static ShortAdModel? _parseAd(dynamic value) {
    if (value is! Map<String, dynamic>) return null;

    final ad = ShortAdModel.fromJson(value);

    return ad.isEmpty ? null : ad;
  }
}
