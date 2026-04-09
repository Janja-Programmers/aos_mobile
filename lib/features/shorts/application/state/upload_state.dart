import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/short.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

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

  // ───────────── INPUT DATA ─────────────
  final File? videoFile;
  final String? selectedAdId;
  final String caption;
  final List<String> hashtags;

  // ───────────── META ─────────────
  final double progress; // 0 → 1
  final String? errorMessage;

  const UploadState({
    required this.status,
    required this.shortId,
    required this.short,
    required this.videoFile,
    required this.selectedAdId,
    required this.caption,
    required this.hashtags,
    required this.progress,
    required this.errorMessage,
  });

  // ───────────── INITIAL ─────────────

  factory UploadState.initial() {
    return const UploadState(
      status: UploadStatus.idle,
      shortId: null,
      short: null,
      videoFile: null,
      selectedAdId: null,
      caption: '',
      hashtags: [],
      progress: 0,
      errorMessage: null,
    );
  }

  // ───────────── HELPERS ─────────────

  bool get isBusy =>
      status == UploadStatus.initializing ||
      status == UploadStatus.uploading ||
      status == UploadStatus.confirming ||
      status == UploadStatus.processing;

  bool get isReady => status == UploadStatus.ready;

  bool get hasError => status == UploadStatus.failed;

  bool get canUpload => videoFile != null && selectedAdId != null && !isBusy;

  // ───────────── COPY ─────────────

  UploadState copyWith({
    UploadStatus? status,
    ShortId? shortId,
    Short? short,
    File? videoFile,
    bool clearVideo = false,
    String? selectedAdId,
    String? caption,
    List<String>? hashtags,
    double? progress,
    String? errorMessage,
    bool clearError = false,
    bool clearShort = false,
  }) {
    return UploadState(
      status: status ?? this.status,
      shortId: shortId ?? this.shortId,
      short: clearShort ? null : (short ?? this.short),

      // 🔥 allow clearing
      videoFile: clearVideo ? null : (videoFile ?? this.videoFile),

      selectedAdId: selectedAdId ?? this.selectedAdId,
      caption: caption ?? this.caption,

      // 🔥 defensive copy
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
    videoFile,
    selectedAdId,
    caption,
    hashtags,
    progress,
    errorMessage,
  ];
}
