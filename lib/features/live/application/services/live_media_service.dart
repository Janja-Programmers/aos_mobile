import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';

class LiveMediaService {
  LiveMediaService(this.liveKit);

  final LiveKitService liveKit;

  lk.LocalVideoTrack? _ownedVideoTrack;
  bool _videoTrackPublished = false;

  Stream<MediaTrackEvent> get events => liveKit.events;
  lk.LocalVideoTrack? get preparedVideoTrack => _ownedVideoTrack;

  Future<lk.LocalVideoTrack> prepareCamera({required bool frontCamera}) async {
    final existing = _ownedVideoTrack;
    if (existing != null) return existing;

    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      throw StateError('Camera permission is required.');
    }

    final track = await lk.LocalVideoTrack.createCameraTrack(
      lk.CameraCaptureOptions(
        cameraPosition: frontCamera
            ? lk.CameraPosition.front
            : lk.CameraPosition.back,
      ),
    );
    _ownedVideoTrack = track;
    _videoTrackPublished = false;
    return track;
  }

  Future<void> joinLive({
    required String wsUrl,
    required String token,
    required AOSLiveRole role,
    bool micEnabled = true,
    bool cameraEnabled = true,
    bool frontCamera = true,
  }) async {
    final shouldPublish =
        role == AOSLiveRole.host || role == AOSLiveRole.cohost;

    _validateWebSocketUrl(wsUrl);

    if (shouldPublish) {
      await _ensureMicrophonePermission(needed: micEnabled);
    }

    try {
      await liveKit.connect(wsUrl: wsUrl, token: token);
      await _preferSpeakerOutput();

      if (!shouldPublish) return;

      await liveKit.enableMicrophone(micEnabled);

      if (!cameraEnabled) return;

      final track =
          _ownedVideoTrack ?? await prepareCamera(frontCamera: frontCamera);
      await liveKit.publishVideoTrack(track);
      _ownedVideoTrack = track;
      _videoTrackPublished = true;
    } on Object {
      await liveKit.disconnect(silent: true);
      await releaseCamera();
      rethrow;
    }
  }

  Future<void> leaveLive() async {
    await liveKit.disconnect();
    await releaseCamera();
  }

  Future<void> releasePreparedCamera() async {
    if (_videoTrackPublished) return;
    await releaseCamera();
  }

  Future<void> releaseCamera() async {
    final track = _ownedVideoTrack;
    _ownedVideoTrack = null;
    _videoTrackPublished = false;
    await track?.stop();
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    if (enabled) {
      await _ensureMicrophonePermission(needed: true);
    }
    await liveKit.enableMicrophone(enabled);
  }

  Future<void> setCameraEnabled({
    required bool enabled,
    required bool frontCamera,
  }) async {
    if (!enabled) {
      await liveKit.enableCamera(false);
      await releaseCamera();
      return;
    }

    final track =
        _ownedVideoTrack ?? await prepareCamera(frontCamera: frontCamera);
    await liveKit.publishVideoTrack(track);
    _ownedVideoTrack = track;
    _videoTrackPublished = true;
  }

  Future<bool> flipCamera() async {
    final ownedTrack = _ownedVideoTrack;
    if (ownedTrack == null) return liveKit.switchCamera();

    final devices = await lk.Hardware.instance.enumerateDevices();
    final cameras = devices
        .where((device) => device.kind == 'videoinput')
        .toList(growable: false);
    if (cameras.length < 2) return false;

    final currentDeviceId = ownedTrack.currentOptions.deviceId;
    final currentIndex = cameras.indexWhere(
      (camera) => camera.deviceId == currentDeviceId,
    );
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % cameras.length;
    await ownedTrack.switchCamera(cameras[nextIndex].deviceId);
    return true;
  }

  List<LiveKitViewerParticipant> getViewerParticipants() {
    return liveKit.getViewerParticipants();
  }

  Future<void> _ensureMicrophonePermission({required bool needed}) async {
    if (!needed) return;
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw StateError('Microphone permission is required.');
    }
  }

  void _validateWebSocketUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw const FormatException('Invalid LiveKit URL.');
    }
    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      throw const FormatException('LiveKit URL must use ws or wss.');
    }
  }

  Future<void> _preferSpeakerOutput() async {
    try {
      await liveKit.switchSpeaker(true);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Could not select speaker output for Live',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
