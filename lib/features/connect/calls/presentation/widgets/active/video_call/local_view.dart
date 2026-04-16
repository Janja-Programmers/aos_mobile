import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class LocalPreview extends StatelessWidget {
  final VideoTrack track;

  const LocalPreview({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      clipBehavior: Clip.hardEdge,
      child: VideoTrackRenderer(track, mirrorMode: VideoViewMirrorMode.mirror),
    );
  }
}
