import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/calls/application/providers/call_providers.dart';
import 'package:go_router/go_router.dart';

class ActiveCallScreen extends ConsumerWidget {
  const ActiveCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Duration
              Text(
                _formatDuration(callState.duration),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              const Spacer(),

              // Placeholder for video/audio
              Expanded(
                child: Center(
                  child: callState.isVideoEnabled
                      ? const Icon(
                          Icons.videocam,
                          size: 80,
                          color: Colors.white,
                        )
                      : const Icon(Icons.call, size: 80, color: Colors.white),
                ),
              ),

              const Spacer(),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: Icon(callState.isMuted ? Icons.mic_off : Icons.mic),
                    onPressed: manager.toggleMute,
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(
                      callState.isSpeakerOn
                          ? Icons.volume_up
                          : Icons.volume_down,
                    ),
                    onPressed: manager.toggleSpeaker,
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(
                      callState.isVideoEnabled
                          ? Icons.videocam
                          : Icons.videocam_off,
                    ),
                    onPressed: manager.toggleVideo,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // End Call
              FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () async {
                  await manager.endCurrentCall();

                  if (context.mounted) {
                    context.pop();
                  }
                },
                child: const Icon(Icons.call_end),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
