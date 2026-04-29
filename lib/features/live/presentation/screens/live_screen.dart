import 'dart:async';

import 'package:africaonlinestores/features/live/domain/live_chat_message.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/floating_hearts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';

import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';

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
  int _heartTrigger = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final liveKit = ref.read(liveKitCoreProvider);
      _mediaSub = liveKit.events.listen(_onMediaEvent);

      final liveId = ref.read(liveManagerProvider).session?.liveId;
      if (liveId != null) {
        ref.read(liveCommentsControllerProvider.notifier).init(liveId);
      }
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

  Future<void> _showLeaveLiveDialog(
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
                Text("Leave Live?", style: context.h5),
                const SizedBox(height: 8),

                Text(
                  "You will exit this live stream.",
                  style: context.p,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                /// 🔴 LEAVE BUTTON
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
                    child: Text("Leave", style: AppTextStylesX(context).button),
                  ),
                ),

                const SizedBox(height: 10),

                /// ⚪ CANCEL
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Stay", style: context.p),
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

    final commentsState = ref.watch(liveCommentsControllerProvider);
    final commentsController = ref.read(
      liveCommentsControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: colors.black,
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
              isHost: state.isHost,
              onEnd: () {
                if (state.isHost) {
                  _showEndLiveDialog(context, manager.endLive);
                } else {
                  _showLeaveLiveDialog(context, manager.leaveLive);
                }
              },
            ),

            /// FLOATING Hearts
            FloatingHearts(trigger: _heartTrigger),

            /// RIGHT ACTIONS
            LiveRightActions(
              onLike: () {
                setState(() {
                  _heartTrigger++;
                });

                manager.sendReaction(reactionType: 'like');
              },
              onProducts: () {},
              onFlip: state.isHost ? manager.flipCamera : () {},
            ),

            /// CHAT
            LiveChatOverlay(
              messages: commentsState.comments
                  .map(
                    (c) =>
                        LiveChatMessage(username: c.userId, message: c.comment),
                  )
                  .toList(),
            ),

            /// INPUT
            LiveInputBar(
              controller: _chatController,
              onSend: () async {
                final text = _chatController.text.trim();
                if (text.isEmpty) return;

                final liveId = state.session?.liveId;
                if (liveId == null) return;

                _chatController.clear();

                await commentsController.addComment(
                  liveId: liveId,
                  comment: text,
                );
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
