import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/selected_media_type.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';

enum UploadStatus {
  idle,
  picked,
  initializing,
  uploading,
  confirming,
  processing,
  ready,
  failed,
}

class UploadState extends Equatable {
  // ───────────── CORE FLOW ─────────────
  final UploadStatus status;
  final ShortId? shortId;
  final Short? short;

  // ───────────── MEDIA (SOURCE OF TRUTH) ─────────────
  final List<SelectedMedia> media;

  // ───────────── METADATA ─────────────
  final String contentMode;
  final String? selectedAdId;
  final String caption;
  final List<String> hashtags;

  // ───────────── META ─────────────
  final double progress;
  final String? errorMessage;

  const UploadState({
    required this.status,
    required this.shortId,
    required this.short,
    required this.media,
    required this.contentMode,
    required this.selectedAdId,
    required this.caption,
    required this.hashtags,
    required this.progress,
    required this.errorMessage,
  });

  factory UploadState.initial() {
    return const UploadState(
      status: UploadStatus.idle,
      shortId: null,
      short: null,
      media: [],
      contentMode: ShortContentModes.shop,
      selectedAdId: null,
      caption: '',
      hashtags: [],
      progress: 0,
      errorMessage: null,
    );
  }

  bool get isBusy =>
      status == UploadStatus.initializing ||
      status == UploadStatus.uploading ||
      status == UploadStatus.confirming ||
      status == UploadStatus.processing;

  bool get isReady => status == UploadStatus.ready;

  bool get hasError => status == UploadStatus.failed;

  bool get hasMedia => media.isNotEmpty;

  SelectedMedia? get primaryMedia => media.isNotEmpty ? media.first : null;

  bool get requiresAd => ShortContentModes.requiresAd(contentMode);

  bool get hasSelectedAd =>
      selectedAdId != null && selectedAdId!.trim().isNotEmpty;

  bool get canUpload {
    if (!hasMedia || isBusy) return false;
    if (requiresAd && !hasSelectedAd) return false;
    return true;
  }

  bool get isVideo => primaryMedia?.type == MediaType.video;

  UploadState copyWith({
    UploadStatus? status,
    ShortId? shortId,
    Short? short,
    List<SelectedMedia>? media,
    String? contentMode,
    String? selectedAdId,
    String? caption,
    List<String>? hashtags,
    double? progress,
    String? errorMessage,
    bool clearError = false,
    bool clearShort = false,
    bool clearSelectedAd = false,
  }) {
    return UploadState(
      status: status ?? this.status,
      shortId: shortId ?? this.shortId,
      short: clearShort ? null : (short ?? this.short),

      media: media ?? this.media,
      contentMode: contentMode ?? this.contentMode,
      selectedAdId: clearSelectedAd ? null : selectedAdId ?? this.selectedAdId,

      caption: caption ?? this.caption,

      hashtags: hashtags != null ? List.unmodifiable(hashtags) : this.hashtags,

      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    shortId,
    short,
    media,
    contentMode,
    selectedAdId,
    caption,
    hashtags,
    progress,
    errorMessage,
  ];
}
