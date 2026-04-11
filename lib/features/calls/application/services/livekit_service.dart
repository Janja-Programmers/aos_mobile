import 'dart:async';

import 'package:africaonlinestores/features/calls/application/services/livekit_track_events.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:africaonlinestores/features/calls/utils/call_logger.dart';

class LiveKitService {
  Room? _room;

  void Function()? _roomEventsCancel;

  final StreamController<LiveKitTrackEvent> _trackController =
      StreamController<LiveKitTrackEvent>.broadcast();

  Stream<LiveKitTrackEvent> get trackEvents => _trackController.stream;

  bool _isConnecting = false;
  bool _isDisconnecting = false;

  // ================= CONNECT =================
  Future<void> connect({
    required String wsUrl,
    required String token,
    required bool isVideo,
  }) async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      CallLogger.room('🔌 Connecting to LiveKit');

      await _requestPermissions(isVideo);

      // Cleanup existing room if any
      if (_room != null) {
        await disconnect(silent: true);
      }

      _room = Room();

      await _room!.connect(wsUrl, token);

      CallLogger.room('✅ Connected to room');

      _listenToRoomEvents();

      await _setupLocalTracks(isVideo);
    } catch (e, s) {
      CallLogger.error('💥 LiveKit connect error', e, s);
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
      CallLogger.room('🔌 Disconnecting room');

      _roomEventsCancel?.call();
      _roomEventsCancel = null;

      await _room?.disconnect();
      _room = null;

      _trackController.add(const TrackClearedEvent());

      if (!silent) {
        CallLogger.room('👋 Room disconnected');
      }
    } catch (e, s) {
      CallLogger.error('💥 LiveKit disconnect error', e, s);
    } finally {
      _isDisconnecting = false;
    }
  }

  // ================= EVENTS =================
  void _listenToRoomEvents() {
    // ✅ Cancel previous listener (correct variable)
    _roomEventsCancel?.call();
    _roomEventsCancel = null;

    // ✅ Assign to class variable (NOT local)
    _roomEventsCancel = _room!.events.listen((event) {
      if (event is TrackSubscribedEvent) {
        CallLogger.room('📡 Track subscribed: ${event.track.kind}');
        _handleTrack(event.track);
      }

      if (event is TrackUnsubscribedEvent) {
        CallLogger.room('📡 Track unsubscribed: ${event.track.kind}');
        _handleTrackRemoved(event.track);
      }

      if (event is ParticipantDisconnectedEvent) {
        CallLogger.room('👤 Participant disconnected');
      }

      if (event is RoomDisconnectedEvent) {
        CallLogger.room('❌ Room disconnected');
      }
    });

    // 🔥 IMPORTANT: Handle existing tracks
    for (final participant in _room!.remoteParticipants.values) {
      for (final pub in participant.trackPublications.values) {
        final track = pub.track;
        if (track != null) {
          _handleTrack(track);
        }
      }
    }
  }

  // ================= TRACK HANDLING =================
  void _handleTrack(Track track) {
    if (track.kind == TrackType.AUDIO) {
      (track as RemoteAudioTrack).start();
      _trackController.add(RemoteAudioTrackEvent(track));
    }

    if (track.kind == TrackType.VIDEO) {
      _trackController.add(RemoteVideoTrackEvent(track as RemoteVideoTrack));
    }
  }

  void _handleTrackRemoved(Track track) {
    if (track.kind == TrackType.VIDEO) {
      _trackController.add(const RemoteVideoRemovedEvent());
    }
  }

  // ================= LOCAL TRACKS =================
  Future<void> _setupLocalTracks(bool isVideo) async {
    final local = _room!.localParticipant;

    await local?.setMicrophoneEnabled(true);

    if (isVideo) {
      await local?.setCameraEnabled(true);

      final pubs = local?.videoTrackPublications ?? [];

      if (pubs.isNotEmpty && pubs.first.track != null) {
        _trackController.add(LocalVideoTrackEvent(pubs.first.track!));
      }
    } else {
      await local?.setCameraEnabled(false);
      _trackController.add(const LocalVideoRemovedEvent());
    }
  }

  // ================= CONTROLS =================
  Future<void> toggleMicrophone(bool enabled) async {
    await _room?.localParticipant?.setMicrophoneEnabled(enabled);
  }

  Future<void> toggleCamera(bool enabled) async {
    await _room?.localParticipant?.setCameraEnabled(enabled);
  }

  Future<void> switchSpeaker(bool enabled) async {
    await Hardware.instance.setSpeakerphoneOn(enabled);
  }

  // ================= PERMISSIONS =================
  Future<void> _requestPermissions(bool isVideo) async {
    final permissions = [Permission.microphone, if (isVideo) Permission.camera];

    await permissions.request();
  }

  // ================= CLEANUP =================
  Future<void> dispose() async {
    await disconnect(silent: true);
    await _trackController.close();
  }
}
