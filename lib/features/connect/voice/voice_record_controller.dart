import 'dart:async';

import 'package:africaonlinestores/features/connect/voice/voice_sound_feedback_service.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/connect/voice/audio_recorder_service.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';

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

    final granted = await _service.hasPermission();
    if (!granted) {
      state = state.copyWith(
        status: VoiceRecordStatus.error,
        error: 'Microphone permission denied',
      );
      return;
    }

    await _soundService.playStartCue();

    await _service.start();

    state = state.copyWith(
      status: VoiceRecordStatus.recording,
      duration: Duration.zero,
      dragDx: 0,
      clearError: true,
      clearRecordedFilePath: true,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });
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
    _timer?.cancel();
    _timer = null;

    if (shouldCancel) {
      await _service.cancel();
      await _soundService.playCancelCue();

      state = state.copyWith(
        status: VoiceRecordStatus.idle,
        duration: Duration.zero,
        dragDx: 0,
        clearRecordedFilePath: true,
      );

      return null;
    }

    final path = await _service.stop();

    state = state.copyWith(
      status: VoiceRecordStatus.idle,
      recordedFilePath: path,
      duration: Duration.zero,
      dragDx: 0,
    );

    return path;
  }

  Future<void> cancelRecording() async {
    _timer?.cancel();
    _timer = null;

    await _service.cancel();
    await _soundService.playCancelCue();

    state = state.copyWith(
      status: VoiceRecordStatus.idle,
      duration: Duration.zero,
      dragDx: 0,
      clearRecordedFilePath: true,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;

    unawaited(_service.dispose());
    unawaited(_soundService.dispose());

    super.dispose();
  }
}
