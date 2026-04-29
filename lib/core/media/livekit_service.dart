import 'dart:async';

import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class LiveKitService {
  lk.Room? _room;
  void Function()? _roomEventsCancel;

  final _controller = StreamController<MediaTrackEvent>.broadcast();
  Stream<MediaTrackEvent> get events => _controller.stream;

  bool _isConnecting = false;
  bool _isDisconnecting = false;

  // ================= CONNECT =================

  Future<lk.Room> connect({
    required String wsUrl,
    required String token,
  }) async {
    if (_isConnecting) return _room!;

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

  // ================= DISCONNECT =================

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

  // ================= EVENTS =================

  void _listen() {
    _roomEventsCancel?.call();

    _roomEventsCancel = _room!.events.listen((event) {
      if (event is lk.TrackSubscribedEvent) {
        final track = event.track;

        if (track.kind == lk.TrackType.AUDIO) {
          (track as lk.RemoteAudioTrack).start();
          _controller.add(RemoteAudioTrackEvent(track));
        }

        if (track.kind == lk.TrackType.VIDEO) {
          _controller.add(RemoteVideoTrackEvent(track as lk.RemoteVideoTrack));
        }
      }

      if (event is lk.TrackUnsubscribedEvent) {
        if (event.track.kind == lk.TrackType.VIDEO) {
          _controller.add(const RemoteVideoRemovedEvent());
        }
      }

      if (event is lk.RoomDisconnectedEvent) {
        _controller.add(const RoomDisconnectedEvent());
      }
    });

    for (final participant in _room!.remoteParticipants.values) {
      for (final pub in participant.trackPublications.values) {
        final track = pub.track;
        if (track == null) continue;

        if (track.kind == lk.TrackType.AUDIO) {
          (track as lk.RemoteAudioTrack).start();
          _controller.add(RemoteAudioTrackEvent(track));
        }

        if (track.kind == lk.TrackType.VIDEO) {
          _controller.add(RemoteVideoTrackEvent(track as lk.RemoteVideoTrack));
        }
      }
    }
  }

  // ================= CONTROLS =================

  Future<void> enableMicrophone(bool enabled) async {
    await _room?.localParticipant?.setMicrophoneEnabled(enabled);
  }

  Future<void> enableCamera(bool enabled) async {
    await _room?.localParticipant?.setCameraEnabled(enabled);
    _emitExistingLocalVideoTrack();
  }

  Future<void> switchSpeaker(bool enabled) async {
    await lk.Hardware.instance.setSpeakerphoneOn(enabled);
  }

  Future<void> switchCamera() async {
    try {
      final participant = _room?.localParticipant;
      if (participant == null) return;

      final pubs = participant.videoTrackPublications;
      if (pubs.isEmpty) return;

      final track = pubs.first.track;
      if (track == null) return;

      final devices = await lk.Hardware.instance.enumerateDevices();
      final cameras = devices.where((d) => d.kind == 'videoinput').toList();

      if (cameras.length < 2) {
        appLogger.i('Only one camera available');
        return;
      }

      /// Get current deviceId
      final currentDeviceId = track.currentOptions.deviceId;

      /// Find next camera
      final currentIndex = cameras.indexWhere(
        (c) => c.deviceId == currentDeviceId,
      );

      final nextIndex = (currentIndex + 1) % cameras.length;
      final nextCamera = cameras[nextIndex];

      /// 🔁 Switch camera
      await track.switchCamera(nextCamera.deviceId);

      appLogger.i('Camera switched to ${nextCamera.label}');
    } catch (e, s) {
      appLogger.e('switchCamera failed', error: e, stackTrace: s);
    }
  }

  void _emitExistingLocalVideoTrack() {
    final local = _room?.localParticipant;
    if (local == null) return;

    final pubs = local.videoTrackPublications;
    if (pubs.isNotEmpty && pubs.first.track != null) {
      _controller.add(LocalVideoTrackEvent(pubs.first.track!));
    } else {
      _controller.add(const LocalVideoRemovedEvent());
    }
  }

  // ================= CLEANUP =================

  Future<void> dispose() async {
    await disconnect(silent: true);
    await _controller.close();
  }
}
