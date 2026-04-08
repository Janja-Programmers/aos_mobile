import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/enums/short_status.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/caption.dart';

class Short extends Equatable {
  final ShortId id;

  /// Playback URL (HLS or MP4)
  final String playbackUrl;

  /// Thumbnail preview
  final String thumbnailUrl;

  /// Optional caption
  final Caption caption;

  /// Hashtags (normalized)
  final List<String> hashtags;

  /// Owner (user id or username for now)
  final String ownerId;

  /// Lifecycle status
  final ShortStatus status;

  /// Engagement snapshot
  final ShortMetrics metrics;

  /// Duration in seconds
  final int durationSeconds;

  const Short({
    required this.id,
    required this.playbackUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.hashtags,
    required this.ownerId,
    required this.status,
    required this.metrics,
    required this.durationSeconds,
  });

  /// Whether this short can be played
  bool get isPlayable => status.isPlayable;

  /// Whether still processing
  bool get isProcessing => status.isProcessing;

  /// Whether retry is allowed
  bool get canRetry => status.canRetry;

  Short copyWith({
    String? playbackUrl,
    String? thumbnailUrl,
    Caption? caption,
    List<String>? hashtags,
    String? ownerId,
    ShortStatus? status,
    ShortMetrics? metrics,
    int? durationSeconds,
  }) {
    return Short(
      id: id,
      playbackUrl: playbackUrl ?? this.playbackUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    playbackUrl,
    thumbnailUrl,
    caption,
    hashtags,
    ownerId,
    status,
    metrics,
    durationSeconds,
  ];
}
