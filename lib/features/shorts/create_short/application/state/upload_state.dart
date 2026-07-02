import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:equatable/equatable.dart';

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
  final UploadStatus status;
  final ShortId? shortId;
  final Short? short;

  final List<SelectedMedia> media;

  final String contentMode;
  final String? selectedAdId;
  final AOSAdListItem? selectedAdPreview;
  final String caption;
  final List<String> hashtags;
  final String audience;
  final bool allowComments;
  final bool allowDownloads;
  final ShortSound selectedSound;

  final double progress;
  final String? errorMessage;

  const UploadState({
    required this.status,
    required this.shortId,
    required this.short,
    required this.media,
    required this.contentMode,
    required this.selectedAdId,
    required this.selectedAdPreview,
    required this.caption,
    required this.hashtags,
    required this.audience,
    required this.allowComments,
    required this.allowDownloads,
    required this.selectedSound,
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
      selectedAdPreview: null,
      caption: '',
      hashtags: [],
      audience: 'everyone',
      allowComments: true,
      allowDownloads: false,
      selectedSound: ShortSound.original,
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
    AOSAdListItem? selectedAdPreview,
    String? caption,
    List<String>? hashtags,
    String? audience,
    bool? allowComments,
    bool? allowDownloads,
    ShortSound? selectedSound,
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
      selectedAdPreview: clearSelectedAd
          ? null
          : selectedAdPreview ?? this.selectedAdPreview,
      caption: caption ?? this.caption,
      hashtags: hashtags != null ? List.unmodifiable(hashtags) : this.hashtags,
      audience: audience ?? this.audience,
      allowComments: allowComments ?? this.allowComments,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      selectedSound: selectedSound ?? this.selectedSound,
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
    selectedAdPreview,
    caption,
    hashtags,
    audience,
    allowComments,
    allowDownloads,
    selectedSound,
    progress,
    errorMessage,
  ];
}
