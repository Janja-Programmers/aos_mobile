// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:convert';

import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class LiveKitViewerParticipant {
  final String livekitIdentity;
  final String accountId;
  final String displayName;
  final String? avatar;

  const LiveKitViewerParticipant({
    required this.livekitIdentity,
    required this.accountId,
    required this.displayName,
    this.avatar,
  });
}

class LiveKitService {
  lk.Room? _room;
  void Function()? _roomEventsCancel;

  final _controller = StreamController<MediaTrackEvent>.broadcast();
  Stream<MediaTrackEvent> get events => _controller.stream;

  void emitCurrentTracks() {
    _emitExistingLocalVideoTrack();
    _emitExistingRemoteVideoTrack();
  }

  bool _isConnecting = false;
  bool _isDisconnecting = false;
  bool _externalCallAudioConfigured = false;
  bool _externalCallAudioActive = false;

  Future<lk.Room> connect({
    required String wsUrl,
    required String token,
  }) async {
    if (_isConnecting && _room != null) return _room!;

    _isConnecting = true;

    try {
      if (_room != null) {
        await disconnect(silent: true);
      }

      _room = lk.Room();
      await _room!.connect(wsUrl, token);

      _listen();

      _controller.add(const RoomConnectedEvent());

      return _room!;
    } catch (e, s) {
      appLogger.e('LiveKit connect failed', error: e, stackTrace: s);
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect({bool silent = false}) async {
    if (_isDisconnecting) return;
    _isDisconnecting = true;

    try {
      _roomEventsCancel?.call();
      _roomEventsCancel = null;

      await _room?.disconnect();
      _room = null;

      _controller.add(const TrackClearedEvent());
      _controller.add(const RoomDisconnectedEvent());

      if (!silent) {
        appLogger.i('👋 LiveKit disconnected');
      }
    } catch (e, s) {
      appLogger.e('disconnect failed', error: e, stackTrace: s);
    } finally {
      _isDisconnecting = false;
    }
  }

  void _listen() {
    _roomEventsCancel?.call();

    _roomEventsCancel = _room!.events.listen((event) {
      if (event is lk.TrackSubscribedEvent) {
        final track = event.track;

        if (track.kind == lk.TrackType.AUDIO) {
          _controller.add(RemoteAudioTrackEvent(track as lk.RemoteAudioTrack));
        }

        if (track.kind == lk.TrackType.VIDEO) {
          _controller.add(RemoteVideoTrackEvent(track as lk.RemoteVideoTrack));
        }
      }

      if (event is lk.TrackUnsubscribedEvent) {
        if (event.track.kind == lk.TrackType.VIDEO) {
          _controller.add(const RemoteVideoRemovedEvent());
          _emitExistingRemoteVideoTrack();
        }
      }

      if (event is lk.RoomDisconnectedEvent) {
        _controller.add(const RoomDisconnectedEvent());
      }

      if (event is lk.RoomReconnectingEvent) {
        _controller.add(const RoomReconnectingEvent());
      }

      if (event is lk.RoomReconnectedEvent) {
        _controller.add(const RoomReconnectedEvent());
        emitCurrentTracks();
      }
    });

    for (final participant in _room!.remoteParticipants.values) {
      for (final pub in participant.trackPublications.values) {
        final track = pub.track;
        if (track == null) continue;

        if (track.kind == lk.TrackType.AUDIO) {
          _controller.add(RemoteAudioTrackEvent(track as lk.RemoteAudioTrack));
        }

        if (track.kind == lk.TrackType.VIDEO) {
          _controller.add(RemoteVideoTrackEvent(track as lk.RemoteVideoTrack));
        }
      }
    }
  }

  Future<void> enableMicrophone(bool enabled) async {
    await _room?.localParticipant?.setMicrophoneEnabled(enabled);
  }

  Future<void> publishVideoTrack(lk.LocalVideoTrack track) async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      throw StateError('LiveKit room is not connected.');
    }

    await participant.publishVideoTrack(track);
    _controller.add(LocalVideoTrackEvent(track));
  }

  Future<void> enableCamera(bool enabled, {bool frontCamera = true}) async {
    if (!enabled) {
      await _room?.localParticipant?.setCameraEnabled(false);
      _emitExistingLocalVideoTrack();
      return;
    }

    await _room?.localParticipant?.setCameraEnabled(
      true,
      cameraCaptureOptions: lk.CameraCaptureOptions(
        cameraPosition: frontCamera
            ? lk.CameraPosition.front
            : lk.CameraPosition.back,
      ),
    );
    _emitExistingLocalVideoTrack();
  }

  /// Uses LiveKit 2.10 routing so wired/Bluetooth headsets keep priority
  /// unless the caller explicitly forces speaker output.
  Future<void> switchSpeaker(bool enabled) async {
    await lk.AudioManager.instance.setSpeakerOutputPreferred(enabled);
  }

  /// Configures LiveKit for an external telephony owner such as iOS CallKit.
  /// `setEngineAvailability` is documented as an Apple-only no-op elsewhere,
  /// so this remains safe for Android while Android keeps automatic routing.
  Future<void> prepareExternalCallAudioLifecycle() async {
    if (!_externalCallAudioConfigured) {
      await lk.AudioManager.instance.setAudioSessionManagementMode(
        lk.AudioSessionManagementMode.externalCallSystem,
      );
      _externalCallAudioConfigured = true;
    }

    if (!_externalCallAudioActive) {
      await lk.AudioManager.instance.setEngineAvailability(
        lk.AudioEngineAvailability.none,
      );
    }
  }

  /// Gates the WebRTC audio engine to CallKit's didActivate/didDeactivate
  /// window on Apple platforms. The LiveKit API is a no-op elsewhere.
  Future<void> setExternalCallAudioSessionActive(bool active) async {
    if (!_externalCallAudioConfigured) {
      await lk.AudioManager.instance.setAudioSessionManagementMode(
        lk.AudioSessionManagementMode.externalCallSystem,
      );
      _externalCallAudioConfigured = true;
    }

    _externalCallAudioActive = active;
    await lk.AudioManager.instance.setEngineAvailability(
      active
          ? lk.AudioEngineAvailability.defaultAvailability
          : lk.AudioEngineAvailability.none,
    );
  }

  Future<void> restoreAutomaticAudioLifecycle() async {
    if (!_externalCallAudioConfigured) return;

    _externalCallAudioActive = false;
    await lk.AudioManager.instance.setEngineAvailability(
      lk.AudioEngineAvailability.defaultAvailability,
    );
    await lk.AudioManager.instance.setAudioSessionManagementMode(
      lk.AudioSessionManagementMode.automatic,
    );
    _externalCallAudioConfigured = false;
  }

  Future<bool> switchCamera() async {
    try {
      final participant = _room?.localParticipant;
      if (participant == null) return false;

      final pubs = participant.videoTrackPublications;
      if (pubs.isEmpty) return false;

      final track = pubs.first.track;
      if (track == null) return false;

      final devices = await lk.Hardware.instance.enumerateDevices();
      final cameras = devices
          .where((device) => device.kind == 'videoinput')
          .toList(growable: false);

      if (cameras.length < 2) {
        appLogger.i('Only one camera available');
        return false;
      }

      final currentDeviceId = track.currentOptions.deviceId;

      final currentIndex = cameras.indexWhere(
        (camera) => camera.deviceId == currentDeviceId,
      );

      final nextIndex = (currentIndex + 1) % cameras.length;
      final nextCamera = cameras[nextIndex];

      await track.switchCamera(nextCamera.deviceId);
      _emitExistingLocalVideoTrack();

      appLogger.i('Camera switched to ${nextCamera.label}');
      return true;
    } catch (e, s) {
      appLogger.e('switchCamera failed', error: e, stackTrace: s);
      return false;
    }
  }

  List<LiveKitViewerParticipant> getViewerParticipants() {
    final room = _room;
    if (room == null) return const [];

    final participants = <LiveKitViewerParticipant>[];
    final seen = <String>{};

    for (final participant in room.remoteParticipants.values) {
      final parsed = _parseViewerParticipant(
        identity: participant.identity,
        metadata: participant.metadata,
      );

      if (parsed == null) continue;
      if (!seen.add(parsed.livekitIdentity)) continue;

      participants.add(parsed);
    }

    participants.sort((a, b) => a.displayName.compareTo(b.displayName));

    return participants;
  }

  LiveKitViewerParticipant? _parseViewerParticipant({
    required String identity,
    required String? metadata,
  }) {
    final metadataMap = _decodeMetadata(metadata);
    final role = metadataMap['role']?.toString().trim().toLowerCase();
    final isGuest = _metadataBool(metadataMap['is_guest']);

    if (role != 'viewer') return null;
    if (isGuest) return null;

    final accountId = metadataMap['account_id']?.toString().trim() ?? '';
    if (!identity.startsWith('aos:participant:') || accountId.isEmpty) {
      return null;
    }

    final displayName = metadataMap['display_name']?.toString().trim();
    final avatar = metadataMap['avatar']?.toString().trim();

    return LiveKitViewerParticipant(
      livekitIdentity: identity,
      accountId: accountId,
      displayName: displayName?.isNotEmpty ?? false ? displayName! : accountId,
      avatar: avatar?.isNotEmpty ?? false ? avatar : null,
    );
  }

  bool _metadataBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  Map<String, Object?> _decodeMetadata(String? metadata) {
    if (metadata == null || metadata.trim().isEmpty) return const {};

    try {
      final decoded = jsonDecode(metadata);
      if (decoded is! Map<Object?, Object?>) return const {};
      return Map<String, Object?>.from(decoded);
    } on Object {
      return const {};
    }
  }

  void _emitExistingLocalVideoTrack() {
    final local = _room?.localParticipant;
    if (local == null) return;

    final pubs = local.videoTrackPublications;
    for (final pub in pubs) {
      final track = pub.track;
      if (track is! lk.LocalVideoTrack) continue;
      _controller.add(LocalVideoTrackEvent(track));
      return;
    }

    _controller.add(const LocalVideoRemovedEvent());
  }

  void _emitExistingRemoteVideoTrack() {
    final room = _room;
    if (room == null) return;

    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.videoTrackPublications) {
        final track = pub.track;
        if (track is! lk.RemoteVideoTrack) continue;
        _controller.add(RemoteVideoTrackEvent(track));
        return;
      }
    }
  }

  Future<void> dispose() async {
    await disconnect(silent: true);
    await restoreAutomaticAudioLifecycle();
    await _controller.close();
  }
}
