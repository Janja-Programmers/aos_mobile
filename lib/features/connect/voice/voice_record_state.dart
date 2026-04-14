enum VoiceRecordStatus { idle, recording, locked, canceling, uploading, error }

class VoiceRecordState {
  const VoiceRecordState({
    this.status = VoiceRecordStatus.idle,
    this.recordedFilePath,
    this.error,
    this.duration = Duration.zero,
    this.dragDx = 0,
  });

  final VoiceRecordStatus status;
  final String? recordedFilePath;
  final String? error;
  final Duration duration;
  final double dragDx;

  bool get isRecording =>
      status == VoiceRecordStatus.recording ||
      status == VoiceRecordStatus.locked;

  bool get isUploading => status == VoiceRecordStatus.uploading;

  VoiceRecordState copyWith({
    VoiceRecordStatus? status,
    String? recordedFilePath,
    String? error,
    Duration? duration,
    double? dragDx,
    bool clearRecordedFilePath = false,
    bool clearError = false,
  }) {
    return VoiceRecordState(
      status: status ?? this.status,
      recordedFilePath: clearRecordedFilePath
          ? null
          : (recordedFilePath ?? this.recordedFilePath),
      error: clearError ? null : (error ?? this.error),
      duration: duration ?? this.duration,
      dragDx: dragDx ?? this.dragDx,
    );
  }
}
