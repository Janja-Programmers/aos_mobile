import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_ad_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_creator_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_metrics_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_viewer_state_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';

class ShortModel {
  final String id;

  final String playbackUrl;
  final String? processedFileUrl;
  final String? thumbnailUrl;
  final double durationSeconds;

  final String contentMode;
  final String visibilityStatus;
  final String audience;
  final bool allowComments;
  final bool allowDownloads;
  final bool isReady;
  final bool isProcessing;
  final bool isFailed;
  final String audioMixStatus;
  final String? audioMixError;

  final String caption;
  final List<String> hashtags;

  final String? status;

  final ShortCreatorModel creator;
  final ShortMetricsModel metrics;
  final ShortViewerStateModel viewerState;

  final ShortAdModel? ad;
  final ShortSound? sound;

  final String? postedAt;

  const ShortModel({
    required this.id,
    required this.playbackUrl,
    this.processedFileUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.contentMode,
    required this.visibilityStatus,
    required this.audience,
    required this.allowComments,
    required this.allowDownloads,
    required this.isReady,
    required this.isProcessing,
    required this.isFailed,
    required this.audioMixStatus,
    this.audioMixError,
    required this.caption,
    required this.hashtags,
    this.status,
    required this.creator,
    required this.metrics,
    required this.viewerState,
    this.ad,
    this.sound,
    this.postedAt,
  });

  factory ShortModel.fromJson(Map<String, dynamic> json) {
    return ShortModel(
      id: json['id']?.toString() ?? '',
      playbackUrl: json['playback_url']?.toString() ?? '',
      processedFileUrl: json['processed_file_url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      durationSeconds: _toDouble(json['duration_seconds']),
      contentMode: _parseContentMode(json['content_mode']),
      visibilityStatus: json['visibility_status']?.toString() ?? 'visible',
      audience: json['audience']?.toString() ?? 'everyone',
      allowComments: _toBool(json['allow_comments'], defaultValue: true),
      allowDownloads: _toBool(json['allow_downloads']),
      isReady: _toBool(json['is_ready']),
      isProcessing: _toBool(json['is_processing']),
      isFailed: _toBool(json['is_failed']),
      audioMixStatus: json['audio_mix_status']?.toString() ?? 'none',
      audioMixError: json['audio_mix_error']?.toString(),
      caption: json['caption']?.toString() ?? '',
      hashtags: _parseStringList(json['hashtags']),
      status: json['status']?.toString(),
      creator: _parseCreator(json['creator']),
      metrics: ShortMetricsModel.fromJson(json),
      ad: _parseAd(json['ad']),
      sound: _parseSound(json['sound']),
      postedAt: json['posted_on']?.toString(),
      viewerState: ShortViewerStateModel.fromJson(
        json['viewer_state'] is Map<String, dynamic>
            ? json['viewer_state'] as Map<String, dynamic>
            : const {},
      ),
    );
  }

  factory ShortModel.fromApiResponse(Map<String, dynamic> json) {
    final message = json['message'];

    if (message is! Map<String, dynamic>) {
      return ShortModel.fromJson(json);
    }

    final data = message['data'];

    if (data is! Map<String, dynamic>) {
      return ShortModel.fromJson(message);
    }

    final item = data['item'];

    if (item is! Map<String, dynamic>) {
      return ShortModel.fromJson(data);
    }

    return ShortModel.fromJson(item);
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

  static ShortCreatorModel _parseCreator(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return ShortCreatorModel.empty();
    }

    return ShortCreatorModel.fromJson(value);
  }

  static ShortAdModel? _parseAd(dynamic value) {
    if (value is! Map<String, dynamic>) return null;

    final ad = ShortAdModel.fromJson(value);

    return ad.isEmpty ? null : ad;
  }

  static ShortSound? _parseSound(dynamic value) {
    if (value is! Map<String, dynamic>) {
      if (value is Map) {
        return ShortSound.fromJson(asJsonMap(value));
      }
      return null;
    }

    final sound = ShortSound.fromJson(value);
    return sound.id.trim().isEmpty ? null : sound;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return defaultValue;

    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
