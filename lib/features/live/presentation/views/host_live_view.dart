import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';

class HostLiveView extends StatelessWidget {
  final LiveStream? live;
  final int viewerCount;
  final lk.VideoTrack? localVideoTrack;
  final VoidCallback onEndLive;

  const HostLiveView({
    super.key,
    required this.live,
    required this.viewerCount,
    required this.localVideoTrack,
    required this.onEndLive,
  });

  @override
  Widget build(BuildContext context) {
    final title = live?.title ?? 'Live';
    final theme = Theme.of(context);

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
              track: localVideoTrack,
              emptyLabel: 'Camera preview unavailable',
              mirror: true,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  ),
                  onPressed: onEndLive,
                  child: const Text('End Live'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
