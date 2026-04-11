import 'package:livekit_client/livekit_client.dart';

abstract class LiveKitTrackEvent {
  const LiveKitTrackEvent();
}

class RemoteAudioTrackEvent extends LiveKitTrackEvent {
  final RemoteAudioTrack track;

  const RemoteAudioTrackEvent(this.track);
}

class RemoteVideoTrackEvent extends LiveKitTrackEvent {
  final RemoteVideoTrack track;

  const RemoteVideoTrackEvent(this.track);
}

class RemoteVideoRemovedEvent extends LiveKitTrackEvent {
  const RemoteVideoRemovedEvent();
}

class LocalVideoTrackEvent extends LiveKitTrackEvent {
  final LocalVideoTrack track;

  const LocalVideoTrackEvent(this.track);
}

class LocalVideoRemovedEvent extends LiveKitTrackEvent {
  const LocalVideoRemovedEvent();
}

class TrackClearedEvent extends LiveKitTrackEvent {
  const TrackClearedEvent();
}
