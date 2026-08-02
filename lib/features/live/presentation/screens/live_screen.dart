import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/sharing/aos_share_links.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/live/application/controllers/live_cohost_controller.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';
import 'package:africaonlinestores/features/live/data/live_cohost_api.dart';
import 'package:africaonlinestores/features/live/domain/live_chat_message.dart';
import 'package:africaonlinestores/features/live/domain/live_cohost.dart';
import 'package:africaonlinestores/features/live/presentation/views/host_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/views/viewer_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/floating_hearts.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_chat_overlay.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_input_bar.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_right_actions.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_top_bar.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:share_plus/share_plus.dart';

class LiveScreen extends ConsumerStatefulWidget {
  final String? liveId;

  const LiveScreen({super.key, this.liveId});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  StreamSubscription<MediaTrackEvent>? _mediaSub;
  StreamSubscription<RealtimeEvent>? _realtimeSub;
  Timer? _commentsRefreshTimer;

  lk.LocalVideoTrack? _localVideoTrack;
  lk.RemoteVideoTrack? _remoteVideoTrack;

  final TextEditingController _chatController = TextEditingController();
  final Set<String> _activatingCohostIds = <String>{};

  int _reactionTrigger = 0;
  String _reactionType = 'like';
  String? _activeLiveId;

  @override
  void initState() {
    super.initState();

    unawaited(
      Future<void>.microtask(() async {
        final liveKit = ref.read(liveKitCoreProvider);
        _mediaSub = liveKit.events.listen(_onMediaEvent);
        liveKit.emitCurrentTracks();
        _realtimeSub = ref
            .read(realtimeServiceProvider)
            .events
            .listen(_onRealtimeEvent);

        final manager = ref.read(liveManagerProvider.notifier);

        if (widget.liveId != null && widget.liveId!.trim().isNotEmpty) {
          await manager.joinLive(liveId: widget.liveId!.trim());
          liveKit.emitCurrentTracks();
        } else {
          liveKit.emitCurrentTracks();
        }

        if (!mounted) return;

        final liveId = ref.read(liveManagerProvider).session?.liveId;
        if (liveId != null && liveId.isNotEmpty) {
          await _prepareLiveSession(liveId);
        }
      }),
    );
  }

  Future<void> _prepareLiveSession(String liveId) async {
    if (_activeLiveId == liveId) return;

    _activeLiveId = liveId;
    _commentsRefreshTimer?.cancel();

    final commentsController = ref.read(
      liveCommentsControllerProvider.notifier,
    );
    final cohostController = ref.read(liveCohostControllerProvider.notifier);

    commentsController.resetForLive(liveId);
    await commentsController.fetchComments(liveId);
    if (!mounted) return;

    await cohostController.load(liveId: liveId);
    if (!mounted) return;

    _commentsRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;

      final currentLiveId = ref.read(liveManagerProvider).session?.liveId;
      if (currentLiveId != liveId) {
        _commentsRefreshTimer?.cancel();
        _commentsRefreshTimer = null;
        return;
      }

      unawaited(
        ref.read(liveCommentsControllerProvider.notifier).fetchComments(liveId),
      );
    });
  }

  void _onRealtimeEvent(RealtimeEvent event) {
    if (!mounted) return;

    final data = asJsonMap(event.data);
    final liveId = data['live_id']?.toString();
    final currentLiveId = ref.read(liveManagerProvider).session?.liveId;

    if (liveId == null || liveId.isEmpty || liveId != currentLiveId) return;

    if (event.type == RealtimeEventType.aosLiveComment) {
      ref
          .read(liveCommentsControllerProvider.notifier)
          .insertFromRealtime(data);
      return;
    }

    if (event.type == RealtimeEventType.aosLiveCommentDeleted) {
      final ids = _deletedMessageIds(data);
      if (ids.isNotEmpty) {
        ref
            .read(liveCommentsControllerProvider.notifier)
            .removeManyFromRealtime(ids);
      }
      return;
    }

    if (event.type == RealtimeEventType.aosLiveReaction) {
      _handleReactionEvent(data);
      return;
    }

    if (_isCohostEvent(event.type)) {
      final cohost = ref
          .read(liveCohostControllerProvider.notifier)
          .applyRealtime(data);
      if (cohost != null) {
        unawaited(_maybeStartAcceptedCohost(cohost));
      }
    }
  }

  Set<String> _deletedMessageIds(Map<String, dynamic> data) {
    final ids = <String>{};
    final list = asJsonList(data['deleted_message_ids']);
    for (final item in list) {
      final value = item?.toString() ?? '';
      if (value.isNotEmpty) ids.add(value);
    }

    final single =
        data['message_id']?.toString() ?? data['comment_id']?.toString() ?? '';
    if (single.isNotEmpty) ids.add(single);

    return ids;
  }

  void _handleReactionEvent(Map<String, dynamic> data) {
    final rawReaction = data['reaction'];
    if (rawReaction is! Map) return;

    final reaction = asJsonMap(rawReaction);
    final reactionType =
        reaction['reaction_type']?.toString() ??
        reaction['type']?.toString() ??
        'like';

    setState(() {
      _reactionType = reactionType;
      _reactionTrigger++;
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

  Future<void> _shareLive({required String liveId, String? title}) async {
    try {
      final link = AosShareLinks.live(liveId);
      final normalizedTitle = title?.trim() ?? '';
      final text = StringBuffer();

      if (normalizedTitle.isNotEmpty) {
        text
          ..writeln(normalizedTitle)
          ..writeln();
      }

      text
        ..writeln(context.l10n.watchThisLiveOnAos)
        ..write(link);

      await SharePlus.instance.share(
        ShareParams(
          title: context.l10n.liveShareAction,
          subject: context.l10n.watchThisLiveOnAos,
          text: text.toString(),
        ),
      );
    } catch (error) {
      debugPrint('Open live share intent failed: $error');
      if (mounted) {
        ShowSnack(context, context.l10n.unableToOpenShareOptions).error();
      }
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

  Future<void> _maybeStartAcceptedCohost(LiveCohost cohost) async {
    final liveState = ref.read(liveManagerProvider);
    if (liveState.isHost || liveState.isCohost || !cohost.isAccepted) return;
    if (liveState.session?.liveId != cohost.liveId) return;
    await _startAcceptedCohost(cohost, liveState.session?.sessionId);
  }

  Future<void> _startAcceptedCohost(
    LiveCohost cohost,
    String? sessionId,
  ) async {
    if (!_activatingCohostIds.add(cohost.id)) return;

    try {
      final cohostApi = ref.read(liveCohostApiProvider);
      final manager = ref.read(liveManagerProvider.notifier);
      final cohostController = ref.read(liveCohostControllerProvider.notifier);

      final tokenResult = await cohostApi.getCohostToken(
        cohostId: cohost.id,
        sessionId: sessionId ?? cohost.sessionId,
      );

      if (!mounted) return;

      final failure = tokenResult.leftOrNull;
      if (failure != null) {
        ShowSnack(context, failure.message).error();
        return;
      }

      final session = tokenResult.rightOrNull;
      if (session == null) {
        ShowSnack(context, 'Could not start co-host session.').error();
        return;
      }

      await manager.startCohostSession(session);
      if (!mounted) return;

      await cohostController.activate(
        cohostId: cohost.id,
        sessionId: session.sessionId ?? sessionId ?? cohost.sessionId,
      );

      if (!mounted) return;
      ShowSnack(context, 'You are now a co-host.').success();
    } finally {
      _activatingCohostIds.remove(cohost.id);
    }
  }

  Future<void> _showCohostSheet({
    required BuildContext context,
    required String liveId,
    required bool isHost,
    String? sessionId,
  }) async {
    final controller = ref.read(liveCohostControllerProvider.notifier);
    final mediaService = ref.read(liveMediaServiceProvider);

    try {
      await controller.load(liveId: liveId);
    } catch (_) {
      if (context.mounted) {
        ShowSnack(context, 'Could not load co-host information.').error();
      }
      return;
    }

    if (!context.mounted) return;

    final List<LiveKitViewerParticipant> viewerCandidates;
    try {
      viewerCandidates = mediaService
          .getViewerParticipants()
          .where(
            (viewer) => viewer.user.isNotEmpty && viewer.sessionId.isNotEmpty,
          )
          .toList(growable: false);
    } catch (_) {
      ShowSnack(
        context,
        'Could not read active viewers for co-hosting.',
      ).error();
      return;
    }

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Co-host', style: context.h5),
                      const SizedBox(height: 8),
                      Text(
                        isHost
                            ? 'Invite an active viewer or manage co-host requests.'
                            : 'Ask the host to bring you into the live.',
                        style: context.p,
                      ),
                      const SizedBox(height: 16),
                      if (isHost)
                        _HostCohostTools(
                          liveId: liveId,
                          viewers: viewerCandidates,
                          state: cohost,
                          controller: controller,
                        )
                      else
                        _ViewerCohostTools(
                          liveId: liveId,
                          sessionId: sessionId,
                          state: cohost,
                          controller: controller,
                          onAccepted: (LiveCohost item) =>
                              _startAcceptedCohost(item, sessionId),
                        ),
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
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _commentsRefreshTimer?.cancel();
    ref.read(liveCommentsControllerProvider.notifier).clear();
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (state.session != null)
            state.isBroadcaster
                ? HostLiveView(
                    localVideoTrack: _localVideoTrack,
                    mirror: state.isFrontCamera,
                  )
                : ViewerLiveView(remoteVideoTrack: _remoteVideoTrack),
          if (state.session != null) ...[
            LiveTopBar(
              viewerCount: state.viewerCount,
              isHost: state.isHost,
              onEnd: () {
                if (state.isHost) {
                  unawaited(_showEndLiveDialog(context, manager.endLive));
                } else {
                  unawaited(_showLeaveLiveDialog(context, manager.leaveLive));
                }
              },
            ),
            FloatingHearts(
              trigger: _reactionTrigger,
              reactionType: _reactionType,
            ),
            LiveRightActions(
              onLike: () => unawaited(manager.sendReaction()),
              onShare: () => unawaited(
                _shareLive(
                  liveId: state.session!.liveId,
                  title: state.live?.title,
                ),
              ),
              onFlip: state.isBroadcaster
                  ? () => unawaited(manager.flipCamera())
                  : () {},
              onMute: state.isBroadcaster
                  ? () =>
                        unawaited(manager.setMicrophoneMuted(!state.isMicMuted))
                  : () {},
              onCohost: () => unawaited(
                _showCohostSheet(
                  context: context,
                  liveId: state.session!.liveId,
                  sessionId: state.session?.sessionId,
                  isHost: state.isHost,
                ),
              ),
              isHost: state.isBroadcaster,
              isMuted: state.isMicMuted,
            ),
            LiveChatOverlay(
              messages: commentsState.comments
                  .map(
                    (comment) => LiveChatMessage(
                      username: comment.authorLabel,
                      message: comment.comment,
                    ),
                  )
                  .toList(growable: false),
            ),
            LiveInputBar(
              controller: _chatController,
              isSending: commentsState.isSubmitting,
              onSend: () async {
                final text = _chatController.text.trim();
                if (text.isEmpty) return;

                final liveId = state.session?.liveId;
                if (liveId == null) return;

                _chatController.clear();

                final sent = await commentsController.addComment(
                  liveId: liveId,
                  comment: text,
                  sessionId: state.session?.sessionId,
                );

                if (!mounted) return;

                if (!sent) {
                  _chatController.text = text;
                  final message =
                      commentsController.errorMessage ??
                      'Could not send comment.';
                  if (context.mounted) ShowSnack(context, message).error();
                }
              },
            ),
          ],
          if (state.status == LiveStatus.loading)
            const Center(child: CircularProgressIndicator()),
          if (state.status == LiveStatus.error)
            Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
                style: context.p.copyWith(color: colors.white),
                textAlign: TextAlign.center,
              ),
            ),
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

class _HostCohostTools extends StatelessWidget {
  final String liveId;
  final List<LiveKitViewerParticipant> viewers;
  final LiveCohostState state;
  final LiveCohostController controller;

  const _HostCohostTools({
    required this.liveId,
    required this.viewers,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final requests = state.items
        .where((item) => item.isViewerRequest || item.isPending)
        .take(6)
        .toList(growable: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active viewers', style: context.pStrong),
        const SizedBox(height: 8),
        if (viewers.isEmpty)
          Text(
            'No eligible authenticated viewers are currently detected in the LiveKit room.',
            style: AppTextStylesX(context).caption,
          )
        else
          ...viewers
              .take(8)
              .map(
                (viewer) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(viewer.displayName),
                  subtitle: Text(viewer.user),
                  trailing: ElevatedButton(
                    onPressed: state.isMutating
                        ? null
                        : () async {
                            final invited = await controller.invite(
                              liveId: liveId,
                              targetUser: viewer.user,
                              sessionId: viewer.sessionId,
                            );
                            if (!context.mounted) return;
                            if (invited != null) {
                              ShowSnack(
                                context,
                                'Co-host invitation sent.',
                              ).success();
                            } else {
                              ShowSnack(
                                context,
                                'Could not invite this viewer as co-host.',
                              ).error();
                            }
                          },
                    child: const Text('Invite'),
                  ),
                ),
              ),
        if (requests.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Requests & invites', style: context.pStrong),
          const SizedBox(height: 8),
          ...requests.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.group_outlined)),
              title: Text(item.displayName),
              subtitle: Text(item.status),
              trailing: item.isPending && item.isViewerRequest
                  ? Wrap(
                      spacing: 6,
                      children: [
                        TextButton(
                          onPressed: state.isMutating
                              ? null
                              : () => unawaited(
                                  controller.respond(
                                    cohostId: item.id,
                                    accept: false,
                                  ),
                                ),
                          child: const Text('Reject'),
                        ),
                        ElevatedButton(
                          onPressed: state.isMutating
                              ? null
                              : () async {
                                  final accepted = await controller.respond(
                                    cohostId: item.id,
                                    accept: true,
                                  );
                                  if (!context.mounted) return;
                                  if (accepted != null) {
                                    ShowSnack(
                                      context,
                                      'Request accepted. Waiting for viewer to connect.',
                                    ).success();
                                  }
                                },
                          child: const Text('Accept'),
                        ),
                      ],
                    )
                  : item.isActiveStatus
                  ? TextButton(
                      onPressed: state.isMutating
                          ? null
                          : () => unawaited(controller.end(cohostId: item.id)),
                      child: const Text('End'),
                    )
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _ViewerCohostTools extends StatelessWidget {
  final String liveId;
  final String? sessionId;
  final LiveCohostState state;
  final LiveCohostController controller;
  final Future<void> Function(LiveCohost item) onAccepted;

  const _ViewerCohostTools({
    required this.liveId,
    required this.sessionId,
    required this.state,
    required this.controller,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final invites = state.items
        .where((item) => item.isHostInvite || item.isPending)
        .take(4)
        .toList(growable: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isMutating
                ? null
                : () async {
                    final requested = await controller.request(
                      liveId: liveId,
                      sessionId: sessionId,
                    );
                    if (!context.mounted) return;
                    if (requested != null) {
                      ShowSnack(context, 'Co-host request sent.').success();
                    } else {
                      ShowSnack(
                        context,
                        'Could not send co-host request.',
                      ).error();
                    }
                  },
            icon: const Icon(Icons.waving_hand_outlined),
            label: const Text('Request to join live'),
          ),
        ),
        if (invites.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...invites.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.group_outlined),
              title: Text(item.displayName),
              subtitle: Text(item.status),
              trailing: item.isHostInvite && item.isPending
                  ? Wrap(
                      spacing: 6,
                      children: [
                        TextButton(
                          onPressed: state.isMutating
                              ? null
                              : () => unawaited(
                                  controller.respond(
                                    cohostId: item.id,
                                    accept: false,
                                  ),
                                ),
                          child: const Text('Reject'),
                        ),
                        ElevatedButton(
                          onPressed: state.isMutating
                              ? null
                              : () async {
                                  final accepted = await controller.respond(
                                    cohostId: item.id,
                                    accept: true,
                                  );
                                  if (accepted != null) {
                                    await onAccepted(accepted);
                                  }
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
    );
  }
}
