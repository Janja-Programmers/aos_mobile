import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/enums/short_status.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_ad.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_viewer_state.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/caption.dart';

class Short extends Equatable {
  final ShortId id;
  final Caption caption;
  final List<String> hashtags;
  final String playbackUrl;
  final String? thumbnailUrl;
  final double durationSeconds;

  final String sellerId;
  final String? sellerShopName;
  final String? sellerAvator;

  final ShortStatus status;
  final ShortMetrics metrics;

  final ShortAd? ad;
  final DateTime? postedAt;

  final ShortViewerState viewerState;

  const Short({
    required this.id,
    required this.playbackUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.caption,
    required this.hashtags,
    required this.sellerId,
    this.sellerShopName,
    this.sellerAvator,
    required this.status,
    required this.metrics,
    required this.viewerState,
    this.ad,
    this.postedAt,
  });

  bool get isPlayable => status.isPlayable;
  bool get isProcessing => status.isProcessing;
  bool get canRetry => status.canRetry;
  bool get isVisible => status.isVisible;

  bool get isLiked => viewerState.liked;
  bool get isWatched => viewerState.watched;

  Short copyWith({
    String? playbackUrl,
    String? thumbnailUrl,
    double? durationSeconds,
    Caption? caption,
    List<String>? hashtags,
    String? sellerId,
    String? sellerShopName,
    String? sellerAvator,
    ShortStatus? status,
    ShortMetrics? metrics,
    ShortAd? ad,
    DateTime? postedAt,
    ShortViewerState? viewerState,
  }) {
    return Short(
      id: id,
      playbackUrl: playbackUrl ?? this.playbackUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      sellerId: sellerId ?? this.sellerId,
      sellerShopName: sellerShopName ?? this.sellerShopName,
      sellerAvator: sellerAvator ?? this.sellerAvator,
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      ad: ad ?? this.ad,
      postedAt: postedAt ?? this.postedAt,
      viewerState: viewerState ?? this.viewerState,
    );
  }

  @override
  List<Object?> get props => [
    id,
    playbackUrl,
    thumbnailUrl,
    durationSeconds,
    caption,
    hashtags,
    sellerId,
    sellerShopName,
    sellerAvator,
    status,
    metrics,
    ad,
    postedAt,
    viewerState,
  ];
}
