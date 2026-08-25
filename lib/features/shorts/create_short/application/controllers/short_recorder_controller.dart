import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_acquisition_service.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';

abstract interface class ShortPermissionGate {
  Future<bool> requestCameraAndMicrophone();
  Future<void> openSettings();
}

class PluginShortPermissionGate implements ShortPermissionGate {
  const PluginShortPermissionGate();

  @override
  Future<bool> requestCameraAndMicrophone() async {
    final statuses = await <Permission>[
      Permission.camera,
      Permission.microphone,
    ].request();
    return statuses.values.every((PermissionStatus status) => status.isGranted);
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}

abstract interface class ShortCameraDriver {
  Widget? get previewWidget;
  Size? get previewSize;
  bool get isRecording;
  int get cameraCount;
  Future<void> initialize(int cameraIndex);
  Future<String> startRecording();
  Future<String> stopRecording();
  Future<void> setFlash(bool enabled);
  Future<void> dispose();
}

class ShortCameraDriverException implements Exception {
  const ShortCameraDriverException({
    required this.message,
    this.permissionDenied = false,
  });

  final String message;
  final bool permissionDenied;

  @override
  String toString() => message;
}

abstract interface class ShortVideoPicker {
  Future<String?> pickVideo();
}

class SharedShortVideoPicker implements ShortVideoPicker {
  const SharedShortVideoPicker(this._acquisition);

  final MediaAcquisitionService _acquisition;

  @override
  Future<String?> pickVideo() async {
    final selected = await _acquisition.pickVideo(
      useCase: MediaUseCase.shortVideo,
    );
    return selected?.path;
  }
}

class ShortRecorderController extends StateNotifier<ShortRecorderState> {
  ShortRecorderController({
    required ShortCameraDriver cameraDriver,
    required ShortVideoPicker videoPicker,
    required ShortPermissionGate permissionGate,
  }) : _cameraDriver = cameraDriver,
       _videoPicker = videoPicker,
       _permissionGate = permissionGate,
       super(ShortRecorderState.initial());

  final ShortCameraDriver _cameraDriver;
  final ShortVideoPicker _videoPicker;
  final ShortPermissionGate _permissionGate;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _operationInProgress = false;
  bool _disposed = false;
  int _operationGeneration = 0;

  Widget? get cameraPreview => _cameraDriver.previewWidget;
  Size? get cameraPreviewSize => _cameraDriver.previewSize;

  Future<void> initialize() async {
    if (_operationInProgress || _disposed) return;
    _operationInProgress = true;
    final generation = ++_operationGeneration;
    state = state.copyWith(
      phase: ShortRecorderPhase.initializing,
      clearError: true,
    );
    try {
      final granted = await _permissionGate.requestCameraAndMicrophone();
      if (_disposed || generation != _operationGeneration) return;
      if (!granted) {
        if (!_disposed) {
          state = state.copyWith(
            phase: ShortRecorderPhase.permissionDenied,
            errorMessage: 'Camera and microphone permission are required.',
          );
        }
        return;
      }

      await _cameraDriver.initialize(state.cameraIndex);
      if (!_disposed && generation == _operationGeneration) {
        state = state.copyWith(
          phase: ShortRecorderPhase.ready,
          cameraCount: _cameraDriver.cameraCount,
          elapsed: Duration.zero,
          clearRecordedPath: true,
          clearError: true,
        );
      }
    } on ShortCameraDriverException catch (error) {
      if (!_disposed && generation == _operationGeneration) {
        state = state.copyWith(
          phase: error.permissionDenied
              ? ShortRecorderPhase.permissionDenied
              : ShortRecorderPhase.error,
          errorMessage: error.message,
        );
      }
    } catch (_) {
      if (!_disposed && generation == _operationGeneration) {
        state = state.copyWith(
          phase: ShortRecorderPhase.unavailable,
          errorMessage: 'No usable camera is available on this device.',
        );
      }
    } finally {
      _operationInProgress = false;
    }
  }

  void setLimit(ShortRecordingLimit value) {
    if (state.isRecording || state.isBusy) return;
    state = state.copyWith(limit: value, elapsed: Duration.zero);
  }

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (_operationInProgress || !state.canRecord || _disposed) return;
    _operationInProgress = true;
    final generation = ++_operationGeneration;
    state = state.copyWith(
      phase: ShortRecorderPhase.starting,
      elapsed: Duration.zero,
      clearRecordedPath: true,
      clearError: true,
    );
    try {
      await _cameraDriver.startRecording();
      if (_disposed || generation != _operationGeneration) {
        if (_cameraDriver.isRecording) {
          await _cameraDriver.stopRecording();
        }
        return;
      }
      _stopwatch
        ..reset()
        ..start();
      state = state.copyWith(phase: ShortRecorderPhase.recording);
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (_disposed || !state.isRecording) return;
        final elapsed = _stopwatch.elapsed;
        if (elapsed >= state.limit.duration) {
          unawaited(stopRecording());
          return;
        }
        state = state.copyWith(elapsed: elapsed);
      });
    } catch (_) {
      if (!_disposed) {
        state = state.copyWith(
          phase: ShortRecorderPhase.error,
          errorMessage: 'Recording could not be started. Please try again.',
        );
      }
    } finally {
      _operationInProgress = false;
    }
  }

  Future<String?> stopRecording() async {
    if (_operationInProgress || !state.isRecording || _disposed) return null;
    _operationInProgress = true;
    _ticker?.cancel();
    _stopwatch.stop();
    state = state.copyWith(
      phase: ShortRecorderPhase.stopping,
      elapsed: _stopwatch.elapsed > state.limit.duration
          ? state.limit.duration
          : _stopwatch.elapsed,
    );
    try {
      final path = await _cameraDriver.stopRecording();
      if (_disposed) return path;
      if (path.isEmpty || !File(path).existsSync()) {
        throw const FileSystemException('Recorded video is missing.');
      }
      state = state.copyWith(
        phase: ShortRecorderPhase.recorded,
        recordedPath: path,
        clearError: true,
      );
      return path;
    } catch (_) {
      if (!_disposed) {
        state = state.copyWith(
          phase: ShortRecorderPhase.error,
          errorMessage: 'Recording could not be saved. Please try again.',
        );
      }
      return null;
    } finally {
      _operationInProgress = false;
    }
  }

  Future<String?> importVideo() async {
    if (_operationInProgress || state.isRecording || _disposed) return null;
    _operationInProgress = true;
    try {
      final path = await _videoPicker.pickVideo();
      if (path == null || path.trim().isEmpty) return null;
      final file = File(path);
      if (!file.existsSync()) return null;
      if (!_disposed) {
        state = state.copyWith(
          phase: ShortRecorderPhase.recorded,
          recordedPath: path,
          elapsed: Duration.zero,
          clearError: true,
        );
      }
      return path;
    } catch (_) {
      if (!_disposed) {
        state = state.copyWith(
          phase: ShortRecorderPhase.error,
          errorMessage: 'The selected video could not be opened.',
        );
      }
      return null;
    } finally {
      _operationInProgress = false;
    }
  }

  Future<void> flipCamera() async {
    if (_operationInProgress || state.isRecording || state.cameraCount < 2) {
      return;
    }
    final next = (state.cameraIndex + 1) % state.cameraCount;
    state = state.copyWith(cameraIndex: next, flashEnabled: false);
    await initialize();
  }

  Future<void> toggleFlash() async {
    if (_operationInProgress || !state.canRecord) return;
    final next = !state.flashEnabled;
    try {
      await _cameraDriver.setFlash(next);
      if (!_disposed) state = state.copyWith(flashEnabled: next);
    } catch (_) {
      if (!_disposed) {
        state = state.copyWith(errorMessage: 'Flash is unavailable.');
      }
    }
  }

  Future<void> onLifecycleChanged(AppLifecycleState lifecycle) async {
    if (_disposed) return;
    if (lifecycle == AppLifecycleState.inactive ||
        lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.detached) {
      await suspendCamera();
      return;
    }
    if (lifecycle == AppLifecycleState.resumed &&
        state.phase != ShortRecorderPhase.recorded) {
      await initialize();
    }
  }

  Future<void> suspendCamera() async {
    if (_disposed) return;
    _operationGeneration++;
    if (state.isRecording) await stopRecording();
    await _cameraDriver.dispose();
    if (!_disposed && state.phase != ShortRecorderPhase.recorded) {
      state = state.copyWith(phase: ShortRecorderPhase.initializing);
    }
  }

  Future<void> openSettings() async {
    await _permissionGate.openSettings();
  }

  @override
  void dispose() {
    _disposed = true;
    _operationGeneration++;
    _ticker?.cancel();
    _stopwatch.stop();
    unawaited(_cameraDriver.dispose());
    super.dispose();
  }
}
