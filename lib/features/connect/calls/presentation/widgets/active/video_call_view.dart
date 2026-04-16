import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/video_call/local_view.dart';

class VideoCallView extends StatelessWidget {
  final Room? room;

  const VideoCallView({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return const Center(child: Text('Connecting...'));
    }

    final localParticipant = room!.localParticipant;
    final remoteParticipants = room!.remoteParticipants.values.toList();

    final remote = remoteParticipants.isNotEmpty
        ? remoteParticipants.first
        : null;

    // =========================
    // 🎥 REMOTE VIDEO TRACK
    // =========================
    VideoTrack? remoteVideoTrack;
    if (remote != null) {
      for (final pub in remote.trackPublications.values) {
        if (pub.kind == TrackType.VIDEO &&
            pub.track != null &&
            pub.subscribed) {
          remoteVideoTrack = pub.track as VideoTrack;
          break;
        }
      }
    }

    // =========================
    // 🤳 LOCAL VIDEO TRACK
    // =========================
    VideoTrack? localVideoTrack;
    if (localParticipant != null) {
      for (final pub in localParticipant.videoTrackPublications) {
        if (pub.track != null) {
          localVideoTrack = pub.track as VideoTrack;
          break;
        }
      }
    }

    return Stack(
      children: [
        // =========================
        // 🎥 REMOTE (FULLSCREEN)
        // =========================
        Positioned.fill(
          child: remoteVideoTrack != null
              ? VideoTrackRenderer(remoteVideoTrack)
              : const _NoRemoteVideo(),
        ),

        // =========================
        // 🤳 LOCAL PREVIEW
        // =========================
        if (localVideoTrack != null)
          Positioned(
            top: 16,
            right: 16,
            child: LocalPreview(track: localVideoTrack),
          ),
      ],
    );
  }
}

class _NoRemoteVideo extends StatelessWidget {
  const _NoRemoteVideo();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text(
        "Waiting for video...",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
