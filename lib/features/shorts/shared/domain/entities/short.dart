import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/enums/short_status.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_ad.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_creator.dart';
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

  final String contentMode;
  final ShortStatus status;
  final String visibilityStatus;
  final String audience;
  final bool allowComments;
  final bool allowDownloads;
  final bool isReady;
  final bool isProcessingFlag;
  final bool isFailedFlag;

  final ShortCreator creator;
  final ShortMetrics metrics;
  final ShortViewerState viewerState;

  final ShortAd? ad;
  final DateTime? postedAt;

  const Short({
    required this.id,
    required this.playbackUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.contentMode,
    required this.caption,
    required this.hashtags,
    required this.status,
    this.visibilityStatus = 'visible',
    this.audience = 'everyone',
    this.allowComments = true,
    this.allowDownloads = false,
    this.isReady = false,
    this.isProcessingFlag = false,
    this.isFailedFlag = false,
    required this.creator,
    required this.metrics,
    required this.viewerState,
    this.ad,
    this.postedAt,
  });

  bool get isPlayable => isReady || status.isPlayable;
  bool get isProcessing => isProcessingFlag || status.isProcessing;
  bool get canRetry => isFailedFlag || status.canRetry;
  bool get isVisible => visibilityStatus == 'visible' && status.isVisible;
  bool get isHidden => visibilityStatus == 'hidden';
  bool get isDeleted =>
      visibilityStatus == 'deleted' || status == ShortStatus.deleted;
  bool get isPrivateAudience => audience != 'everyone';

  bool get isLiked => viewerState.liked;
  bool get isWatched => viewerState.watched;

  bool get isOwner => viewerState.isOwner;
  bool get canEdit => viewerState.canEdit;
  bool get canDelete => viewerState.canDelete;
  bool get canReport => viewerState.canReport;

  bool get isFollowingCreator => viewerState.isFollowing;
  bool get isCreatorVerified => creator.isVerified;

  String get sellerId => creator.sellerId;
  String get sellerShopName => creator.displayName;
  String? get sellerAvatar => creator.avatar;

  Short copyWith({
    String? playbackUrl,
    String? thumbnailUrl,
    double? durationSeconds,
    String? contentMode,
    Caption? caption,
    List<String>? hashtags,
    ShortStatus? status,
    String? visibilityStatus,
    String? audience,
    bool? allowComments,
    bool? allowDownloads,
    bool? isReady,
    bool? isProcessingFlag,
    bool? isFailedFlag,
    ShortCreator? creator,
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
      contentMode: contentMode ?? this.contentMode,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      status: status ?? this.status,
      visibilityStatus: visibilityStatus ?? this.visibilityStatus,
      audience: audience ?? this.audience,
      allowComments: allowComments ?? this.allowComments,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      isReady: isReady ?? this.isReady,
      isProcessingFlag: isProcessingFlag ?? this.isProcessingFlag,
      isFailedFlag: isFailedFlag ?? this.isFailedFlag,
      creator: creator ?? this.creator,
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
    contentMode,
    caption,
    hashtags,
    status,
    visibilityStatus,
    audience,
    allowComments,
    allowDownloads,
    isReady,
    isProcessingFlag,
    isFailedFlag,
    creator,
    metrics,
    ad,
    postedAt,
    viewerState,
  ];
}
