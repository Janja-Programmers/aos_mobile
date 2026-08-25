import 'dart:async';

import 'package:africaonlinestores/core/media/application/media_camera_resource_coordinator.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';

class LiveMediaService {
  LiveMediaService(
    this.liveKit, {
    MediaCameraResourceCoordinator? cameraResources,
  }) : _cameraResources = cameraResources ?? MediaCameraResourceCoordinator();

  final LiveKitService liveKit;
  final MediaCameraResourceCoordinator _cameraResources;

  lk.LocalVideoTrack? _ownedVideoTrack;
  MediaCameraLease? _cameraLease;
  bool _videoTrackPublished = false;
  Future<void> _cameraTransitionTail = Future<void>.value();

  Stream<MediaTrackEvent> get events => liveKit.events;
  lk.LocalVideoTrack? get preparedVideoTrack => _ownedVideoTrack;

  Future<lk.LocalVideoTrack> prepareCamera({required bool frontCamera}) {
    return _enqueueCameraTransition(
      () => _prepareCamera(frontCamera: frontCamera),
    );
  }

  Future<lk.LocalVideoTrack> _prepareCamera({required bool frontCamera}) async {
    final existing = _ownedVideoTrack;
    if (existing != null) return existing;

    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      throw StateError('Camera permission is required.');
    }

    _cameraLease ??= _cameraResources.acquire(MediaCameraOwner.live);
    try {
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
    } on Object {
      _cameraLease?.release();
      _cameraLease = null;
      rethrow;
    }
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

  Future<void> releasePreparedCamera() {
    return _enqueueCameraTransition(() async {
      if (_videoTrackPublished) return;
      await _releaseCamera();
    });
  }

  Future<void> releaseCamera() {
    return _enqueueCameraTransition(_releaseCamera);
  }

  Future<void> _releaseCamera() async {
    final track = _ownedVideoTrack;
    _ownedVideoTrack = null;
    _videoTrackPublished = false;
    try {
      await track?.stop();
    } finally {
      _cameraLease?.release();
      _cameraLease = null;
    }
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

  Future<bool> flipCamera() {
    return _enqueueCameraTransition(_flipCamera);
  }

  Future<bool> _flipCamera() async {
    final ownedTrack = _ownedVideoTrack;
    if (ownedTrack == null) return liveKit.switchCamera();

    final devices = await lk.Hardware.instance.enumerateDevices();
    final cameras = devices
        .where((device) => device.kind == 'videoinput')
        .toList(growable: false);
    if (cameras.length < 2) return false;

    final currentOptions = ownedTrack.currentOptions;
    final currentPosition = currentOptions is lk.CameraCaptureOptions
        ? currentOptions.cameraPosition
        : lk.CameraPosition.front;
    final nextPosition = currentPosition == lk.CameraPosition.front
        ? lk.CameraPosition.back
        : lk.CameraPosition.front;

    await ownedTrack.setCameraPosition(nextPosition);
    return true;
  }

  Future<T> _enqueueCameraTransition<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _cameraTransitionTail = _cameraTransitionTail.then<void>((_) async {
      try {
        completer.complete(await operation());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
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
