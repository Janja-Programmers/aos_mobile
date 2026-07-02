import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class ViewerLiveView extends StatelessWidget {
  final lk.VideoTrack? remoteVideoTrack;

  const ViewerLiveView({super.key, required this.remoteVideoTrack});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LiveVideoStage(
        track: remoteVideoTrack,
        emptyLabel: 'waiting for host...',
      ),
    );
  }
}
