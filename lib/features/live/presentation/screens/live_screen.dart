import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/live/application/controllers/live_cohost_controller.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';
import 'package:africaonlinestores/features/live/data/live_cohost_api.dart';
import 'package:africaonlinestores/features/live/domain/live_chat_message.dart';
import 'package:africaonlinestores/features/live/presentation/views/host_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/views/viewer_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/floating_hearts.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_chat_overlay.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_input_bar.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_right_actions.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_top_bar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class LiveScreen extends ConsumerStatefulWidget {
  final String? liveId;

  const LiveScreen({super.key, this.liveId});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  StreamSubscription<MediaTrackEvent>? _mediaSub;
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  lk.LocalVideoTrack? _localVideoTrack;
  lk.RemoteVideoTrack? _remoteVideoTrack;

  final TextEditingController _chatController = TextEditingController();
  int _heartTrigger = 0;
  bool _micMuted = false;

  @override
  void initState() {
    super.initState();

    unawaited(
      Future<void>.microtask(() async {
        final liveKit = ref.read(liveKitCoreProvider);
        _mediaSub = liveKit.events.listen(_onMediaEvent);
        _realtimeSub = ref.read(realtimeServiceProvider).events.listen((event) {
          final data = asJsonMap(event.data);
          if (event.type == RealtimeEventType.aosLiveComment) {
            ref
                .read(liveCommentsControllerProvider.notifier)
                .insertFromRealtime(data);
          } else if (event.type == RealtimeEventType.aosLiveCommentDeleted) {
            final id =
                data['message_id']?.toString() ??
                data['comment_id']?.toString() ??
                '';
            if (id.isNotEmpty) {
              ref
                  .read(liveCommentsControllerProvider.notifier)
                  .removeFromRealtime(id);
            }
          } else if (_isCohostEvent(event.type)) {
            ref.read(liveCohostControllerProvider.notifier).applyRealtime(data);
          }
        });

        final manager = ref.read(liveManagerProvider.notifier);

        if (widget.liveId != null && widget.liveId!.trim().isNotEmpty) {
          await manager.joinLive(liveId: widget.liveId!.trim());
        }

        final liveId = ref.read(liveManagerProvider).session?.liveId;
        if (liveId != null) {
          await ref.read(liveCommentsControllerProvider.notifier).init(liveId);
        }
      }),
    );
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
                Text('End Live Stream?', style: context.h5),

                const SizedBox(height: 8),

                Text(
                  'Your live stream will end and viewers will be disconnected.',
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
                      'End Stream',
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
                    child: Text('Continue Streaming', style: context.p),
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
                Text('Leave Live?', style: context.h5),
                const SizedBox(height: 8),

                Text(
                  'You will exit this live stream.',
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
                    child: Text('Leave', style: AppTextStylesX(context).button),
                  ),
                ),

                const SizedBox(height: 10),

                /// ⚪ CANCEL
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Stay', style: context.p),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isCohostEvent(RealtimeEventType type) {
    return type == RealtimeEventType.aosLiveCohostInvited ||
        type == RealtimeEventType.aosLiveCohostRequestReceived ||
        type == RealtimeEventType.aosLiveCohostAccepted ||
        type == RealtimeEventType.aosLiveCohostRejected ||
        type == RealtimeEventType.aosLiveCohostCancelled ||
        type == RealtimeEventType.aosLiveCohostActivated ||
        type == RealtimeEventType.aosLiveCohostStarted ||
        type == RealtimeEventType.aosLiveCohostEnded;
  }

  Future<void> _showCohostSheet({
    required BuildContext context,
    required String liveId,
    required bool isHost,
    String? sessionId,
  }) async {
    final targetController = TextEditingController();
    await ref.read(liveCohostControllerProvider.notifier).load(liveId: liveId);

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Consumer(
          builder: (context, ref, _) {
            final cohost = ref.watch(liveCohostControllerProvider);
            final controller = ref.read(liveCohostControllerProvider.notifier);

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Co-host', style: context.h5),
                    const SizedBox(height: 8),
                    Text(
                      isHost
                          ? 'Invite a viewer or manage requests.'
                          : 'Ask the host to bring you into the live.',
                      style: context.p,
                    ),
                    const SizedBox(height: 16),
                    if (isHost) ...[
                      TextField(
                        controller: targetController,
                        decoration: const InputDecoration(
                          labelText: 'Viewer email / user id',
                          prefixIcon: Icon(Icons.person_search_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: cohost.isMutating
                              ? null
                              : () async {
                                  final user = targetController.text.trim();
                                  if (user.isEmpty) return;
                                  await controller.invite(
                                    liveId: liveId,
                                    targetUser: user,
                                    sessionId: sessionId,
                                  );
                                  targetController.clear();
                                },
                          icon: const Icon(Icons.group_add_outlined),
                          label: const Text('Invite co-host'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (cohost.items.isNotEmpty)
                        ...cohost.items
                            .take(6)
                            .map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person_outline),
                                ),
                                title: Text(item.displayName),
                                subtitle: Text(item.status),
                                trailing: item.isPending
                                    ? Wrap(
                                        spacing: 6,
                                        children: [
                                          TextButton(
                                            onPressed: () => controller.respond(
                                              cohostId: item.id,
                                              accept: false,
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final accepted = await controller
                                                  .respond(
                                                    cohostId: item.id,
                                                    accept: true,
                                                  );
                                              if (accepted != null) {
                                                await ref
                                                    .read(liveCohostApiProvider)
                                                    .activateCohost(
                                                      cohostId: accepted.id,
                                                      sessionId: sessionId,
                                                    );
                                              }
                                            },
                                            child: const Text('Accept'),
                                          ),
                                        ],
                                      )
                                    : item.isActiveStatus
                                    ? TextButton(
                                        onPressed: () =>
                                            controller.end(cohostId: item.id),
                                        child: const Text('End'),
                                      )
                                    : null,
                              ),
                            ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: cohost.isMutating
                              ? null
                              : () => controller.request(
                                  liveId: liveId,
                                  sessionId: sessionId,
                                ),
                          icon: const Icon(Icons.waving_hand_outlined),
                          label: const Text('Request to join live'),
                        ),
                      ),
                      if (cohost.items.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...cohost.items
                            .take(3)
                            .map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.group_outlined),
                                title: Text(item.displayName),
                                subtitle: Text(item.status),
                                trailing:
                                    item.requestType == 'invite' &&
                                        item.isPending
                                    ? Wrap(
                                        spacing: 6,
                                        children: [
                                          TextButton(
                                            onPressed: () => controller.respond(
                                              cohostId: item.id,
                                              accept: false,
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final accepted = await controller
                                                  .respond(
                                                    cohostId: item.id,
                                                    accept: true,
                                                  );
                                              if (accepted == null) return;
                                              final token = await ref
                                                  .read(liveCohostApiProvider)
                                                  .getCohostToken(
                                                    cohostId: accepted.id,
                                                    sessionId: sessionId,
                                                  );
                                              token.fold(
                                                (failure) => ShowSnack(
                                                  context,
                                                  failure.message,
                                                ).error(),
                                                (session) => ref
                                                    .read(
                                                      liveManagerProvider
                                                          .notifier,
                                                    )
                                                    .startCohostSession(
                                                      session,
                                                    ),
                                              );
                                            },
                                            child: const Text('Accept'),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                      ],
                    ],
                    if (cohost.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        cohost.errorMessage!,
                        style: AppTextStylesX(
                          context,
                        ).caption.copyWith(color: context.appColors.error),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    targetController.dispose();
  }

  @override
  void dispose() {
    _chatController.dispose();
    unawaited(_mediaSub?.cancel());
    unawaited(_realtimeSub?.cancel());
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

                manager.sendReaction();
              },
              onFlip: state.isHost ? manager.flipCamera : () {},
              onMute: () async {
                final next = !_micMuted;
                setState(() => _micMuted = next);
                await manager.setMicrophoneMuted(next);
              },
              onCohost: () => _showCohostSheet(
                context: context,
                liveId: state.session!.liveId,
                sessionId: state.session?.sessionId,
                isHost: state.isHost,
              ),
              isHost: state.isHost,
              isMuted: _micMuted,
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
