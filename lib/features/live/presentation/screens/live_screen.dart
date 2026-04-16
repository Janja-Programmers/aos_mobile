import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';

import 'package:africaonlinestores/features/live/presentation/views/host_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/views/viewer_live_view.dart';

import 'package:africaonlinestores/features/live/presentation/widgets/live_chat_overlay.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_input_bar.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_right_actions.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_top_bar.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  StreamSubscription<MediaTrackEvent>? _mediaSub;

  lk.LocalVideoTrack? _localVideoTrack;
  lk.RemoteVideoTrack? _remoteVideoTrack;

  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final liveKit = ref.read(liveKitCoreProvider);
      _mediaSub = liveKit.events.listen(_onMediaEvent);
    });
  }

  void _onMediaEvent(MediaTrackEvent event) {
    if (!mounted) return;

    if (event is LocalVideoTrackEvent) {
      setState(() => _localVideoTrack = event.track);
      return;
    }

    if (event is LocalVideoRemovedEvent) {
      setState(() => _localVideoTrack = null);
      return;
    }

    if (event is RemoteVideoTrackEvent) {
      setState(() => _remoteVideoTrack = event.track);
      return;
    }

    if (event is RemoteVideoRemovedEvent || event is TrackClearedEvent) {
      setState(() {
        _localVideoTrack = null;
        _remoteVideoTrack = null;
      });
      return;
    }
  }

  Future<void> _showEndLiveDialog(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("End Live Stream?", style: context.h5),

                const SizedBox(height: 8),

                Text(
                  "Your live stream will end and viewers will be disconnected.",
                  style: context.p,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                /// 🔴 END STREAM BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    child: Text(
                      "End Stream",
                      style: AppTextStylesX(context).button,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// ⚪ CONTINUE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Continue Streaming", style: context.p),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _mediaSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveManagerProvider);
    final manager = ref.read(liveManagerProvider.notifier);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ================= VIDEO LAYER =================
          if (state.session != null)
            state.isHost
                ? HostLiveView(localVideoTrack: _localVideoTrack)
                : ViewerLiveView(remoteVideoTrack: _remoteVideoTrack),

          /// ================= OVERLAYS (ONLY IF SESSION EXISTS) =================
          if (state.session != null) ...[
            /// TOP BAR
            LiveTopBar(
              viewerCount: state.viewerCount,
              duration: state.duration,
              onEnd: () => _showEndLiveDialog(context, manager.endLive),
            ),

            /// RIGHT ACTIONS
            LiveRightActions(
              onLike: () {},
              onProducts: () {},
              onFlip: state.isHost ? manager.flipCamera : () {},
            ),

            /// CHAT
            const LiveChatOverlay(messages: []),

            /// INPUT
            LiveInputBar(
              controller: _chatController,
              onSend: () {
                final text = _chatController.text.trim();
                if (text.isEmpty) return;

                // manager.sendMessage(text); // assuming exists
                _chatController.clear();
              },
            ),
          ],

          /// ================= LOADING =================
          if (state.status == LiveStatus.loading)
            const Center(child: CircularProgressIndicator()),

          /// ================= ERROR (RARE FALLBACK) =================
          if (state.status == LiveStatus.error)
            Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
                style: context.p.copyWith(color: colors.white),
              ),
            ),

          /// ================= ENDED =================
          if (state.status == LiveStatus.ended)
            Center(
              child: Text(
                'Live ended',
                style: context.p.copyWith(color: colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
