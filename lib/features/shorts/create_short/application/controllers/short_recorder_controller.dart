import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
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
  CameraController? get cameraController;
  bool get isRecording;
  int get cameraCount;
  Future<void> initialize(int cameraIndex);
  Future<String> startRecording();
  Future<String> stopRecording();
  Future<void> setFlash(bool enabled);
  Future<void> dispose();
}

class PluginShortCameraDriver implements ShortCameraDriver {
  List<CameraDescription> _cameras = const <CameraDescription>[];
  CameraController? _controller;

  @override
  CameraController? get cameraController => _controller;

  @override
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  @override
  int get cameraCount => _cameras.length;

  @override
  Future<void> initialize(int cameraIndex) async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) throw StateError('No camera is available.');
    final boundedIndex = cameraIndex.clamp(0, _cameras.length - 1).toInt();
    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    final controller = CameraController(
      _cameras[boundedIndex],
      ResolutionPreset.high,
    );
    _controller = controller;
    await controller.initialize();
  }

  @override
  Future<String> startRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Camera is not ready.');
    }
    if (controller.value.isRecordingVideo) {
      throw StateError('A recording is already active.');
    }
    await controller.startVideoRecording();
    return '';
  }

  @override
  Future<String> stopRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) {
      throw StateError('No recording is active.');
    }
    final file = await controller.stopVideoRecording();
    return file.path;
  }

  @override
  Future<void> setFlash(bool enabled) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}

abstract interface class ShortVideoPicker {
  Future<String?> pickVideo();
}

class ImagePickerShortVideoPicker implements ShortVideoPicker {
  ImagePickerShortVideoPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pickVideo() async {
    final selected = await _picker.pickVideo(source: ImageSource.gallery);
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

  CameraController? get cameraController => _cameraDriver.cameraController;

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
    } on CameraException catch (error) {
      if (!_disposed && generation == _operationGeneration) {
        state = state.copyWith(
          phase: _isPermissionError(error)
              ? ShortRecorderPhase.permissionDenied
              : ShortRecorderPhase.error,
          errorMessage: error.description ?? 'Could not initialize the camera.',
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
      _operationGeneration++;
      if (state.isRecording) await stopRecording();
      await _cameraDriver.dispose();
      if (!_disposed && state.phase != ShortRecorderPhase.recorded) {
        state = state.copyWith(phase: ShortRecorderPhase.initializing);
      }
      return;
    }
    if (lifecycle == AppLifecycleState.resumed &&
        state.phase != ShortRecorderPhase.recorded) {
      await initialize();
    }
  }

  Future<void> openSettings() async {
    await _permissionGate.openSettings();
  }

  bool _isPermissionError(CameraException error) {
    final code = error.code.toLowerCase();
    return code.contains('accessdenied') || code.contains('permission');
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
