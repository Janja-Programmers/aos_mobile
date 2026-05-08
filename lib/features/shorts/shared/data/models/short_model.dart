import 'package:africaonlinestores/features/shorts/shared/data/models/short_ad_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_metrics_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_viewer_state_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';

class ShortModel {
  final String id;

  final String playbackUrl;
  final String thumbnailUrl;
  final int durationSeconds;

  final String contentMode;

  final String caption;
  final List<String> hashtags;

  final String sellerId;
  final String? sellerShopName;
  final String? sellerAvator;

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
    required this.contentMode,
    required this.caption,
    required this.hashtags,
    required this.sellerId,
    this.sellerShopName,
    this.sellerAvator,
    this.status,
    required this.metrics,
    required this.viewerState,
    this.ad,
    this.postedAt,
  });

  factory ShortModel.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>? ?? {};

    return ShortModel(
      id: json['id'] as String? ?? '',

      playbackUrl: json['playback_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',

      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,

      contentMode: _parseContentMode(json['content_mode']),

      caption: json['caption'] as String? ?? '',

      hashtags: (json['hashtags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      sellerId: seller['id'] as String? ?? '',
      sellerShopName: seller['shop_name'] as String?,
      sellerAvator: seller['avatar'] as String?,

      status: json['status'] as String?,

      metrics: ShortMetricsModel.fromJson(json),

      ad: _parseAd(json['ad']),

      postedAt: json['posted_on'] as String?,

      viewerState: ShortViewerStateModel.fromJson(
        json['viewer_state'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  static String _parseContentMode(dynamic value) {
    final mode = value?.toString().trim().toLowerCase();

    if (mode == null || mode.isEmpty) {
      return ShortContentModes.shop;
    }

    if (!ShortContentModes.isValid(mode)) {
      return ShortContentModes.shop;
    }

    return mode;
  }

  static ShortAdModel? _parseAd(dynamic value) {
    if (value is! Map<String, dynamic>) return null;

    final ad = ShortAdModel.fromJson(value);

    return ad.isEmpty ? null : ad;
  }
}
