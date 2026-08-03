import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/voice/audio_recorder_service.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';
import 'package:africaonlinestores/features/connect/voice/voice_sound_feedback_service.dart';
import 'package:flutter_riverpod/legacy.dart';

class VoiceRecordController extends StateNotifier<VoiceRecordState> {
  VoiceRecordController(this._service, this._soundService)
    : super(const VoiceRecordState());

  final AudioRecorderService _service;
  final VoiceSoundFeedbackService _soundService;
  Timer? _timer;

  static const double cancelThreshold = -100;
  static const double lockThreshold = -80;

  Future<void> startRecording() async {
    if (state.isRecording || state.isUploading) return;

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
      );

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !state.isRecording) return;
        state = state.copyWith(
          duration: state.duration + const Duration(seconds: 1),
        );
      });
    } catch (error, stackTrace) {
      appLogger.e(
        'Voice recording could not start',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      state = state.copyWith(
        status: VoiceRecordStatus.error,
        error: VoiceRecordError.startFailed,
      );
    }
  }

  void updateDrag(double dx) {
    if (!state.isRecording) return;

    final nextStatus = dx <= cancelThreshold
        ? VoiceRecordStatus.canceling
        : state.status == VoiceRecordStatus.locked
        ? VoiceRecordStatus.locked
        : VoiceRecordStatus.recording;

    state = state.copyWith(dragDx: dx, status: nextStatus);
  }

  void lockRecording() {
    if (!state.isRecording) return;
    state = state.copyWith(status: VoiceRecordStatus.locked, dragDx: 0);
  }

  Future<String?> finishRecording() async {
    if (!state.isRecording) return null;

    final shouldCancel = state.status == VoiceRecordStatus.canceling;
    _stopTimer();

    try {
      if (shouldCancel) {
        await _service.cancel();
        await _soundService.playCancelCue();
        if (!mounted) return null;

        state = state.copyWith(
          status: VoiceRecordStatus.idle,
          duration: Duration.zero,
          dragDx: 0,
          clearRecordedFilePath: true,
        );
        return null;
      }

      final path = await _service.stop();
      if (!mounted) return null;

      state = state.copyWith(
        status: VoiceRecordStatus.idle,
        recordedFilePath: path,
        duration: Duration.zero,
        dragDx: 0,
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
      );
      return null;
    }
  }

  Future<void> cancelRecording() async {
    _stopTimer();

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
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    unawaited(_service.dispose());
    unawaited(_soundService.dispose());
    super.dispose();
  }
}
