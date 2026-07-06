import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class HostLiveView extends StatelessWidget {
  final lk.VideoTrack? localVideoTrack;
  final bool mirror;

  const HostLiveView({
    super.key,
    required this.localVideoTrack,
    this.mirror = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LiveVideoStage(
        track: localVideoTrack,
        emptyLabel: 'Camera preview unavailable',
        mirror: mirror,
      ),
    );
  }
}
