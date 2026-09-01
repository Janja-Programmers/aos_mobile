import 'dart:io';

import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_recorder_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'recorder has deterministic transitions and ignores duplicate calls',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'short-recorder-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final driver = _FakeCameraDriver(
        outputPath: '${directory.path}${Platform.pathSeparator}recorded.mp4',
      );
      final controller = ShortRecorderController(
        cameraDriver: driver,
        videoPicker: const _FakeVideoPicker(),
        permissionGate: const _GrantedPermissionGate(),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.state.phase, ShortRecorderPhase.ready);
      expect(driver.lastEnableAudio, isTrue);

      await controller.startRecording();
      await controller.startRecording();
      expect(controller.state.phase, ShortRecorderPhase.recording);
      expect(driver.startCalls, 1);

      final output = await controller.stopRecording();
      await controller.stopRecording();
      expect(output, driver.outputPath);
      expect(controller.state.phase, ShortRecorderPhase.recorded);
      expect(driver.stopCalls, 1);

      await controller.suspendCamera();
      expect(controller.state.phase, ShortRecorderPhase.recorded);
      expect(driver.disposeCalls, 1);
    },
  );

  test('microphone can be disabled before recording', () async {
    final driver = _FakeCameraDriver(outputPath: '/unused.mp4');
    final permissionGate = _RecordingPermissionGate();
    final controller = ShortRecorderController(
      cameraDriver: driver,
      videoPicker: const _FakeVideoPicker(),
      permissionGate: permissionGate,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.toggleMicrophone();

    expect(controller.state.microphoneEnabled, isFalse);
    expect(driver.lastEnableAudio, isFalse);
    expect(permissionGate.microphoneRequests, <bool>[true, false]);
  });

  test('denied permissions produce an explicit permission state', () async {
    final controller = ShortRecorderController(
      cameraDriver: _FakeCameraDriver(outputPath: '/unused.mp4'),
      videoPicker: const _FakeVideoPicker(),
      permissionGate: const _DeniedPermissionGate(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.state.phase, ShortRecorderPhase.permissionDenied);
    expect(controller.state.errorMessage, isNotEmpty);
  });
}

final class _FakeCameraDriver implements ShortCameraDriver {
  _FakeCameraDriver({required this.outputPath});

  final String outputPath;
  bool _recording = false;
  int startCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  bool? lastEnableAudio;

  @override
  Widget? get previewWidget => null;

  @override
  Size? get previewSize => null;

  @override
  int get cameraCount => 2;

  @override
  bool get isRecording => _recording;

  @override
  Future<void> dispose() async {
    disposeCalls += 1;
    _recording = false;
  }

  @override
  Future<void> initialize(int cameraIndex, {required bool enableAudio}) async {
    lastEnableAudio = enableAudio;
  }

  @override
  Future<void> setFlash(bool enabled) async {}

  @override
  Future<String> startRecording() async {
    startCalls += 1;
    _recording = true;
    return '';
  }

  @override
  Future<String> stopRecording() async {
    stopCalls += 1;
    _recording = false;
    await File(outputPath).writeAsBytes(const <int>[0, 1, 2]);
    return outputPath;
  }
}

final class _FakeVideoPicker implements ShortVideoPicker {
  const _FakeVideoPicker();

  @override
  Future<String?> pickVideo() async => null;
}

final class _GrantedPermissionGate implements ShortPermissionGate {
  const _GrantedPermissionGate();

  @override
  Future<void> openSettings() async {}

  @override
  Future<bool> requestCameraAndMicrophone({
    required bool microphoneEnabled,
  }) async => true;
}

final class _DeniedPermissionGate implements ShortPermissionGate {
  const _DeniedPermissionGate();

  @override
  Future<void> openSettings() async {}

  @override
  Future<bool> requestCameraAndMicrophone({
    required bool microphoneEnabled,
  }) async => false;
}

final class _RecordingPermissionGate implements ShortPermissionGate {
  final List<bool> microphoneRequests = <bool>[];

  @override
  Future<void> openSettings() async {}

  @override
  Future<bool> requestCameraAndMicrophone({
    required bool microphoneEnabled,
  }) async {
    microphoneRequests.add(microphoneEnabled);
    return true;
  }
}
