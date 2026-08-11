import 'package:livekit_client/livekit_client.dart';

abstract class MediaTrackEvent {
  const MediaTrackEvent();
}

// ================= TRACK =================

class RemoteAudioTrackEvent extends MediaTrackEvent {
  final RemoteAudioTrack track;
  const RemoteAudioTrackEvent(this.track);
}

class RemoteVideoTrackEvent extends MediaTrackEvent {
  final RemoteVideoTrack track;
  const RemoteVideoTrackEvent(this.track);
}

class RemoteVideoRemovedEvent extends MediaTrackEvent {
  const RemoteVideoRemovedEvent();
}

class LocalVideoTrackEvent extends MediaTrackEvent {
  final LocalVideoTrack track;
  const LocalVideoTrackEvent(this.track);
}

class LocalVideoRemovedEvent extends MediaTrackEvent {
  const LocalVideoRemovedEvent();
}

class TrackClearedEvent extends MediaTrackEvent {
  const TrackClearedEvent();
}

// ================= ROOM =================

class RoomConnectedEvent extends MediaTrackEvent {
  const RoomConnectedEvent();
}

class RoomReconnectingEvent extends MediaTrackEvent {
  const RoomReconnectingEvent();
}

class RoomReconnectedEvent extends MediaTrackEvent {
  const RoomReconnectedEvent();
}

class RoomDisconnectedEvent extends MediaTrackEvent {
  const RoomDisconnectedEvent();
}
