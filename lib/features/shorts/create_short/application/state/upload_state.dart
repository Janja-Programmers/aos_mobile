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
  publishing,
  processing,
  ready,
  failed,
}

class UploadState extends Equatable {
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
    required this.saveToDevice,
    required this.savedToDevice,
    required this.selectedSound,
    required this.progress,
    required this.errorMessage,
  });

  factory UploadState.initial() => const UploadState(
    status: UploadStatus.idle,
    shortId: null,
    short: null,
    media: <SelectedMedia>[],
    contentMode: ShortContentModes.geo,
    selectedAdId: null,
    selectedAdPreview: null,
    caption: '',
    hashtags: <String>[],
    audience: 'everyone',
    allowComments: true,
    allowDownloads: false,
    saveToDevice: false,
    savedToDevice: false,
    selectedSound: ShortSound.original,
    progress: 0,
    errorMessage: null,
  );

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
  final bool saveToDevice;
  final bool savedToDevice;
  final ShortSound selectedSound;
  final double progress;
  final String? errorMessage;

  bool get isBusy => switch (status) {
    UploadStatus.initializing ||
    UploadStatus.uploading ||
    UploadStatus.confirming ||
    UploadStatus.publishing ||
    UploadStatus.processing => true,
    _ => false,
  };

  bool get isReady => status == UploadStatus.ready;
  bool get hasError => status == UploadStatus.failed;
  bool get hasMedia => media.isNotEmpty;
  SelectedMedia? get primaryMedia => media.isEmpty ? null : media.first;
  bool get hasSelectedAd => selectedAdId?.trim().isNotEmpty ?? false;
  bool get isVideo => primaryMedia?.type == MediaType.video;

  bool get canUpload => hasMedia && isVideo && !isBusy && shortId == null;

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
    bool? saveToDevice,
    bool? savedToDevice,
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
      short: clearShort ? null : short ?? this.short,
      media: media == null
          ? this.media
          : List<SelectedMedia>.unmodifiable(media),
      contentMode: contentMode ?? this.contentMode,
      selectedAdId: clearSelectedAd ? null : selectedAdId ?? this.selectedAdId,
      selectedAdPreview: clearSelectedAd
          ? null
          : selectedAdPreview ?? this.selectedAdPreview,
      caption: caption ?? this.caption,
      hashtags: hashtags == null
          ? this.hashtags
          : List<String>.unmodifiable(hashtags),
      audience: audience ?? this.audience,
      allowComments: allowComments ?? this.allowComments,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      saveToDevice: saveToDevice ?? this.saveToDevice,
      savedToDevice: savedToDevice ?? this.savedToDevice,
      selectedSound: selectedSound ?? this.selectedSound,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
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
    saveToDevice,
    savedToDevice,
    selectedSound,
    progress,
    errorMessage,
  ];
}
