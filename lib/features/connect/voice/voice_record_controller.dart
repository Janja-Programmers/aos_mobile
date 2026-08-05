import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/voice/audio_recorder_service.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';
import 'package:africaonlinestores/features/connect/voice/voice_sound_feedback_service.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:record/record.dart';

class VoiceRecordController extends StateNotifier<VoiceRecordState> {
  VoiceRecordController(this._service, this._soundService)
    : super(const VoiceRecordState());

  final AudioRecorderService _service;
  final VoiceSoundFeedbackService _soundService;
  Timer? _timer;
  // ignore: cancel_subscriptions
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  static const double cancelThreshold = -100;
  static const double lockThreshold = -80;
  static const int _maxAmplitudeSamples = 28;

  Future<void> startRecording() async {
    if (state.isActive || state.isUploading) return;

    state = state.copyWith(
      status: VoiceRecordStatus.idle,
      clearError: true,
      clearRecordedFilePath: true,
      clearAmplitudes: true,
    );

    try {
      final granted = await _service.hasPermission();
      if (!mounted) return;
      if (!granted) {
        state = state.copyWith(
          status: VoiceRecordStatus.error,
          error: VoiceRecordError.microphonePermissionDenied,
        );
        return;
      }

      await _soundService.playStartCue();
      if (!mounted) return;

      await _service.start();
      if (!mounted) {
        await _service.cancel();
        return;
      }

      state = state.copyWith(
        status: VoiceRecordStatus.recording,
        duration: Duration.zero,
        dragDx: 0,
        clearError: true,
        clearRecordedFilePath: true,
        clearAmplitudes: true,
      );

      _startTimer();
      _startAmplitudeMonitoring();
    } catch (error, stackTrace) {
      appLogger.e(
        'Voice recording could not start',
        error: error,
        stackTrace: stackTrace,
      );
      await _stopAmplitudeMonitoring();
      if (!mounted) return;
      state = state.copyWith(
        status: VoiceRecordStatus.error,
        error: VoiceRecordError.startFailed,
        clearAmplitudes: true,
      );
    }
  }

  void updateDrag(double dx) {
    if (!state.isActive || state.isPaused) return;

    final nextStatus = dx <= cancelThreshold
        ? VoiceRecordStatus.canceling
        : state.status == VoiceRecordStatus.locked
        ? VoiceRecordStatus.locked
        : VoiceRecordStatus.recording;

    state = state.copyWith(dragDx: dx, status: nextStatus);
  }

  void lockRecording() {
    if (!state.isActive || state.isPaused) return;
    state = state.copyWith(status: VoiceRecordStatus.locked, dragDx: 0);
  }

  Future<void> pauseRecording() async {
    if (!state.isActive || state.isPaused) return;

    try {
      await _service.pause();
      if (!mounted) return;
      _stopTimer();
      state = state.copyWith(status: VoiceRecordStatus.paused, dragDx: 0);
    } catch (error, stackTrace) {
      appLogger.w(
        'Voice recording could not be paused.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> resumeRecording() async {
    if (!state.isPaused) return;

    try {
      await _service.resume();
      if (!mounted) return;
      state = state.copyWith(status: VoiceRecordStatus.recording);
      _startTimer();
    } catch (error, stackTrace) {
      appLogger.w(
        'Voice recording could not be resumed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String?> finishRecording() async {
    if (!state.isActive) return null;

    _stopTimer();
    await _stopAmplitudeMonitoring();

    try {
      final path = await _service.stop();
      if (!mounted) return null;

      state = state.copyWith(
        status: VoiceRecordStatus.idle,
        recordedFilePath: path,
        duration: Duration.zero,
        dragDx: 0,
        clearAmplitudes: true,
      );
      return path;
    } catch (error, stackTrace) {
      appLogger.e(
        'Voice recording could not finish',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return null;
      state = state.copyWith(
        status: VoiceRecordStatus.error,
        error: VoiceRecordError.finishFailed,
        duration: Duration.zero,
        dragDx: 0,
        clearAmplitudes: true,
      );
      return null;
    }
  }

  Future<void> cancelRecording() async {
    _stopTimer();
    await _stopAmplitudeMonitoring();

    try {
      await _service.cancel();
      await _soundService.playCancelCue();
    } catch (error, stackTrace) {
      appLogger.e(
        'Voice recording cancellation failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (!mounted) return;
    state = state.copyWith(
      status: VoiceRecordStatus.idle,
      duration: Duration.zero,
      dragDx: 0,
      clearRecordedFilePath: true,
      clearAmplitudes: true,
    );
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !state.isActive || state.isPaused) return;
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });
  }

  void _startAmplitudeMonitoring() {
    unawaited(_stopAmplitudeMonitoring());
    _amplitudeSubscription = _service
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen(
          (amplitude) {
            if (!mounted || !state.isActive || state.isPaused) return;
            final normalized = ((amplitude.current + 60) / 60)
                .clamp(0.08, 1.0)
                .toDouble();
            final samples = <double>[...state.amplitudes, normalized];
            if (samples.length > _maxAmplitudeSamples) {
              samples.removeRange(0, samples.length - _maxAmplitudeSamples);
            }
            state = state.copyWith(amplitudes: samples);
          },
          onError: (Object error, StackTrace stackTrace) {
            appLogger.w(
              'Voice amplitude monitoring stopped.',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );
  }

  Future<void> _stopAmplitudeMonitoring() async {
    final subscription = _amplitudeSubscription;
    _amplitudeSubscription = null;
    await subscription?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    unawaited(_stopAmplitudeMonitoring());
    unawaited(_service.dispose());
    unawaited(_soundService.dispose());
    super.dispose();
  }
}
