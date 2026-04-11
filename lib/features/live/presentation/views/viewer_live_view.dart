import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';

class ViewerLiveView extends StatelessWidget {
  final LiveStream? live;
  final int viewerCount;
  final lk.VideoTrack? remoteVideoTrack;
  final VoidCallback onLeaveLive;

  const ViewerLiveView({
    super.key,
    required this.live,
    required this.viewerCount,
    required this.remoteVideoTrack,
    required this.onLeaveLive,
  });

  @override
  Widget build(BuildContext context) {
    final title = live?.title ?? 'Live';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('👀 $viewerCount')),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LiveVideoStage(
              track: remoteVideoTrack,
              emptyLabel: 'Waiting for host video...',
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onLeaveLive,
                  child: const Text('Leave Live'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
