import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';

class HostLiveView extends StatelessWidget {
  final lk.VideoTrack? localVideoTrack;

  const HostLiveView({super.key, required this.localVideoTrack});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LiveVideoStage(
        track: localVideoTrack,
        emptyLabel: 'Camera preview unavailable',
        mirror: true,
      ),
    );
  }
}
