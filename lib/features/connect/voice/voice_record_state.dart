enum VoiceRecordStatus {
  idle,
  recording,
  paused,
  locked,
  canceling,
  uploading,
  error,
}

enum VoiceRecordError { microphonePermissionDenied, startFailed, finishFailed }

class VoiceRecordState {
  const VoiceRecordState({
    this.status = VoiceRecordStatus.idle,
    this.recordedFilePath,
    this.error,
    this.duration = Duration.zero,
    this.dragDx = 0,
    this.amplitudes = const <double>[],
  });

  final VoiceRecordStatus status;
  final String? recordedFilePath;
  final VoiceRecordError? error;
  final Duration duration;
  final double dragDx;
  final List<double> amplitudes;

  bool get isActive =>
      status == VoiceRecordStatus.recording ||
      status == VoiceRecordStatus.paused ||
      status == VoiceRecordStatus.locked ||
      status == VoiceRecordStatus.canceling;

  bool get isRecording => isActive;
  bool get isPaused => status == VoiceRecordStatus.paused;
  bool get isUploading => status == VoiceRecordStatus.uploading;

  VoiceRecordState copyWith({
    VoiceRecordStatus? status,
    String? recordedFilePath,
    VoiceRecordError? error,
    Duration? duration,
    double? dragDx,
    List<double>? amplitudes,
    bool clearRecordedFilePath = false,
    bool clearError = false,
    bool clearAmplitudes = false,
  }) {
    return VoiceRecordState(
      status: status ?? this.status,
      recordedFilePath: clearRecordedFilePath
          ? null
          : (recordedFilePath ?? this.recordedFilePath),
      error: clearError ? null : (error ?? this.error),
      duration: duration ?? this.duration,
      dragDx: dragDx ?? this.dragDx,
      amplitudes: clearAmplitudes
          ? const <double>[]
          : List<double>.unmodifiable(amplitudes ?? this.amplitudes),
    );
  }
}
