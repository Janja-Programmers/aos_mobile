import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/sharing/aos_share_links.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_forward_conversation_picker.dart';
import 'package:africaonlinestores/features/live/application/controllers/live_cohost_controller.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/application/state/room_state_enum.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';
import 'package:africaonlinestores/features/live/domain/live_chat_message.dart';
import 'package:africaonlinestores/features/live/domain/live_cohost.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/features/live/presentation/views/host_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/views/viewer_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/floating_hearts.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_chat_overlay.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_input_bar.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_right_actions.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_top_bar.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:share_plus/share_plus.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key, this.liveId});

  final String? liveId;

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  final TextEditingController _chatController = TextEditingController();

  StreamSubscription<MediaTrackEvent>? _mediaSubscription;
  lk.LocalVideoTrack? _localVideoTrack;
  lk.RemoteVideoTrack? _remoteVideoTrack;
  String? _preparedLiveId;
  bool _isInitializing = true;
  int _initializationGeneration = 0;

  @override
  void initState() {
    super.initState();
    final liveKit = ref.read(liveKitCoreProvider);
    _mediaSubscription = liveKit.events.listen(_onMediaEvent);
    liveKit.emitCurrentTracks();
    unawaited(_initialize(++_initializationGeneration));
  }

  @override
  void didUpdateWidget(covariant LiveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liveId?.trim() == widget.liveId?.trim()) return;
    _preparedLiveId = null;
    _isInitializing = true;
    unawaited(_initialize(++_initializationGeneration));
  }

  Future<void> _initialize(int generation) async {
    final requestedLiveId = widget.liveId?.trim() ?? '';
    if (requestedLiveId.isNotEmpty) {
      final existingState = ref.read(liveManagerProvider);
      final shouldRefresh =
          existingState.hasActiveRoom &&
          existingState.session?.liveId == requestedLiveId;
      final manager = ref.read(liveManagerProvider.notifier);
      final joined = await manager.joinLive(liveId: requestedLiveId);
      if (joined && shouldRefresh) await manager.refreshActiveLive();
    }
    if (!mounted || generation != _initializationGeneration) return;
    setState(() => _isInitializing = false);

    ref.read(liveKitCoreProvider).emitCurrentTracks();
    final live = ref.read(liveManagerProvider).live;
    if (live == null || !live.isActive) return;
    await _prepareDurableState(live.id);
  }

  Future<void> _prepareDurableState(String liveId) async {
    if (_preparedLiveId == liveId) return;
    _preparedLiveId = liveId;

    final comments = ref.read(liveCommentsControllerProvider.notifier);
    comments.resetForLive(liveId);
    await comments.fetchComments(liveId);
    if (!mounted || ref.read(liveManagerProvider).live?.id != liveId) return;

    final live = ref.read(liveManagerProvider).live;
    if (live == null) return;
    final cohosts = ref.read(liveCohostControllerProvider.notifier);
    cohosts.hydrate(live);
    if (live.viewerState.isHost || live.viewerState.cohostWorkflow != null) {
      await cohosts.load(liveId: liveId);
    }
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
      if (_remoteVideoTrack == null) {
        setState(() => _remoteVideoTrack = event.track);
      }
      return;
    }
    if (event is RemoteVideoRemovedEvent) {
      setState(() => _remoteVideoTrack = null);
      return;
    }
    if (event is TrackClearedEvent) {
      setState(() {
        _localVideoTrack = null;
        _remoteVideoTrack = null;
      });
    }
  }

  Future<void> _submitComment() async {
    final state = ref.read(liveManagerProvider);
    final live = state.live;
    final text = _chatController.text.trim();
    if (live == null || !live.viewerState.canComment || text.isEmpty) return;

    _chatController.clear();
    final comments = ref.read(liveCommentsControllerProvider.notifier);
    final sent = await comments.addComment(
      liveId: live.id,
      comment: text,
      sessionId: state.session?.sessionId,
    );
    if (!mounted || sent) return;

    _chatController.text = text;
    ShowSnack(
      context,
      comments.errorMessage ?? 'Could not send comment.',
    ).error();
  }

  Future<void> _confirmEndOrLeave() async {
    final state = ref.read(liveManagerProvider);
    if (state.session == null || state.isEnding) return;

    final canEnd = state.live?.viewerState.canEnd ?? false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(canEnd ? 'End Live?' : 'Leave Live?'),
          content: Text(
            canEnd
                ? 'The Live will end for everyone.'
                : 'You will leave this Live.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(canEnd ? 'Continue streaming' : 'Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(canEnd ? 'End' : 'Leave'),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) return;

    final manager = ref.read(liveManagerProvider.notifier);
    if (canEnd) {
      await manager.endLive();
    } else {
      final activeCohostId = state.activeCohostId;
      if (state.isCohost && activeCohostId != null) {
        final cohostEnded = await ref
            .read(liveCohostControllerProvider.notifier)
            .end(cohostId: activeCohostId, resumeAsViewer: false);
        if (!mounted) return;
        if (!cohostEnded) {
          ShowSnack(context, 'Could not leave co-hosting.').error();
          return;
        }
      }
      await manager.leaveLive();
    }
  }

  Future<void> _showShareOptions({
    required String liveId,
    required String title,
    required bool canShareToChat,
  }) async {
    final action = await showModalBottomSheet<_ShareAction>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              if (canShareToChat)
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded),
                  title: const Text('Share to AOS Chat'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_ShareAction.aosChat),
                ),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded),
                title: const Text('Share with another app'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_ShareAction.external),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _ShareAction.aosChat:
        await _shareToAosChat(liveId);
        break;
      case _ShareAction.external:
        await _shareExternally(liveId: liveId, title: title);
        break;
    }
  }

  Future<void> _shareToAosChat(String liveId) async {
    final conversations = await showChatForwardConversationPicker(
      context: context,
      currentConversationId: '',
    );
    if (!mounted || conversations == null || conversations.isEmpty) return;

    try {
      await ref
          .read(liveSharingServiceProvider)
          .shareToChats(
            liveId: liveId,
            conversationIds: conversations.map((item) => item.id),
          );
      if (!mounted) return;
      ShowSnack(context, 'Live shared to AOS Chat.').success();
    } on Failure catch (failure) {
      if (!mounted) return;
      ShowSnack(context, failure.message).error();
    } on Object {
      if (!mounted) return;
      ShowSnack(context, 'Could not share this Live to AOS Chat.').error();
    }
  }

  Future<void> _shareExternally({
    required String liveId,
    required String title,
  }) async {
    try {
      final link = AosShareLinks.live(liveId);
      final text = title.trim().isEmpty
          ? '${context.l10n.watchThisLiveOnAos}\n$link'
          : '${title.trim()}\n\n${context.l10n.watchThisLiveOnAos}\n$link';
      await SharePlus.instance.share(
        ShareParams(
          title: context.l10n.liveShareAction,
          subject: context.l10n.watchThisLiveOnAos,
          text: text,
        ),
      );
    } on Object {
      if (!mounted) return;
      ShowSnack(context, context.l10n.unableToOpenShareOptions).error();
    }
  }

  Future<void> _showCohostSheet() async {
    final liveState = ref.read(liveManagerProvider);
    final live = liveState.live;
    final session = liveState.session;
    if (live == null || session == null) return;

    final controller = ref.read(liveCohostControllerProvider.notifier);
    await controller.load(liveId: live.id);
    if (!mounted || ref.read(liveManagerProvider).live?.id != live.id) return;

    final viewers = live.viewerState.canInviteCohost
        ? ref.read(liveMediaServiceProvider).getViewerParticipants()
        : const <LiveKitViewerParticipant>[];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, child) {
            final cohostState = ref.watch(liveCohostControllerProvider);
            final cohostController = ref.read(
              liveCohostControllerProvider.notifier,
            );

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: .72,
              minChildSize: .38,
              maxChildSize: .92,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    18,
                    16,
                    MediaQuery.viewInsetsOf(context).bottom + 24,
                  ),
                  children: [
                    Text('Co-host', style: context.h5),
                    const SizedBox(height: 12),
                    if (live.viewerState.canInviteCohost)
                      _HostCohostTools(
                        liveId: live.id,
                        viewers: viewers,
                        state: cohostState,
                        controller: cohostController,
                      )
                    else
                      _ViewerCohostTools(
                        liveId: live.id,
                        sessionId: session.sessionId,
                        canRequest: live.viewerState.canRequestCohost,
                        state: cohostState,
                        controller: cohostController,
                      ),
                    if (cohostState.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        cohostState.errorMessage!,
                        style: AppTextStylesX(
                          context,
                        ).caption.copyWith(color: context.appColors.error),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveManagerProvider);
    final live = state.live;
    final viewerState = live?.viewerState;
    final commentsState = ref.watch(liveCommentsControllerProvider);
    final cohostState = ref.watch(liveCohostControllerProvider);
    final colors = context.appColors;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardVisible = keyboardInset > 0;

    final canComment = viewerState?.canComment ?? false;
    final canReact = viewerState?.canReact ?? false;
    final canUseCohost =
        viewerState != null &&
        (viewerState.canInviteCohost ||
            viewerState.canRequestCohost ||
            viewerState.isCohost ||
            viewerState.cohostWorkflow != null ||
            cohostState.currentWorkflow != null);
    final canShareToChat = canComment || (viewerState?.isHost ?? false);

    return PopScope<Object?>(
      canPop: state.session == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmEndOrLeave());
      },
      child: Scaffold(
        backgroundColor: colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            if (state.session != null)
              _buildMedia(state.isHost, state.isCohost),
            if (state.session != null && live != null) ...[
              LiveTopBar(
                viewerCount: state.viewerCount,
                reactionCount: live.reactionCount,
                hostName: live.host.displayName,
                hostAvatar: live.host.avatarUrl,
                title: live.title,
                isHost: viewerState?.canEnd ?? false,
                isEnding: state.isEnding,
                onEnd: () => unawaited(_confirmEndOrLeave()),
              ),
              FloatingHearts(
                trigger: state.reactionTrigger,
                reactionType: state.lastReactionType,
              ),
              if (!keyboardVisible)
                LiveRightActions(
                  onLike: () => unawaited(
                    ref
                        .read(liveManagerProvider.notifier)
                        .sendReaction(LiveReactionType.like),
                  ),
                  onReaction: (reaction) => unawaited(
                    ref
                        .read(liveManagerProvider.notifier)
                        .sendReaction(reaction),
                  ),
                  onShare: () => unawaited(
                    _showShareOptions(
                      liveId: live.id,
                      title: live.title,
                      canShareToChat: canShareToChat,
                    ),
                  ),
                  onFlip: () => unawaited(
                    ref.read(liveManagerProvider.notifier).flipCamera(),
                  ),
                  onMute: () => unawaited(
                    ref
                        .read(liveManagerProvider.notifier)
                        .setMicrophoneMuted(!state.isMicMuted),
                  ),
                  onCohost: () => unawaited(_showCohostSheet()),
                  isHost: state.isBroadcaster,
                  isMuted: state.isMicMuted,
                  showReaction: canReact,
                  showCohost: canUseCohost,
                ),
              LiveChatOverlay(
                bottom: canComment ? keyboardInset + 112 : 18,
                messages: commentsState.comments
                    .map(
                      (comment) => LiveChatMessage(
                        username: comment.authorLabel,
                        message: comment.comment,
                      ),
                    )
                    .toList(growable: false),
              ),
              if (canComment)
                LiveInputBar(
                  controller: _chatController,
                  isSending: commentsState.isSubmitting,
                  onSend: _submitComment,
                ),
            ],
            if (state.roomState == RoomState.reconnecting)
              const _LiveStatusBanner(label: 'Reconnecting…'),
            if (_isInitializing || state.status == LiveStatus.loading)
              const Center(child: CircularProgressIndicator()),
            if (state.status == LiveStatus.error)
              _LiveTerminalState(
                message: state.errorMessage ?? 'Could not open this Live.',
                onClose: _close,
              ),
            if (state.status == LiveStatus.ended)
              _LiveTerminalState(
                message: 'This Live has ended.',
                onClose: _close,
              ),
            if (!_isInitializing &&
                state.status == LiveStatus.idle &&
                state.session == null)
              _LiveTerminalState(
                message: 'This Live is unavailable.',
                onClose: _close,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia(bool isHost, bool isCohost) {
    if (isCohost) {
      return Stack(
        children: [
          ViewerLiveView(remoteVideoTrack: _remoteVideoTrack),
          PositionedDirectional(
            top: 150,
            end: 12,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 104,
                  height: 152,
                  child: LiveVideoStage(
                    track: _localVideoTrack,
                    emptyLabel: 'Camera',
                    mirror: ref.read(liveManagerProvider).isFrontCamera,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (isHost) {
      return Stack(
        children: [
          HostLiveView(
            localVideoTrack: _localVideoTrack,
            mirror: ref.read(liveManagerProvider).isFrontCamera,
          ),
          if (_remoteVideoTrack != null)
            PositionedDirectional(
              top: 150,
              end: 12,
              child: SafeArea(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 104,
                    height: 152,
                    child: LiveVideoStage(
                      track: _remoteVideoTrack,
                      emptyLabel: 'Co-host',
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return ViewerLiveView(remoteVideoTrack: _remoteVideoTrack);
  }

  void _close() {
    unawaited(_closeAsync());
  }

  Future<void> _closeAsync() async {
    await Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    final manager = ref.read(liveManagerProvider.notifier);
    manager.hideLiveUi();
    unawaited(manager.leaveLive());
    ref.read(liveCommentsControllerProvider.notifier).clear();
    ref.read(liveCohostControllerProvider.notifier).clear();
    _chatController.dispose();
    unawaited(_mediaSubscription?.cancel());
    super.dispose();
  }
}

enum _ShareAction { aosChat, external }

class _LiveStatusBanner extends StatelessWidget {
  const _LiveStatusBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: SafeArea(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .68),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveTerminalState extends StatelessWidget {
  const _LiveTerminalState({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: .72),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: context.h6.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: onClose,
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HostCohostTools extends StatelessWidget {
  const _HostCohostTools({
    required this.liveId,
    required this.viewers,
    required this.state,
    required this.controller,
  });

  final String liveId;
  final List<LiveKitViewerParticipant> viewers;
  final LiveCohostState state;
  final LiveCohostController controller;

  @override
  Widget build(BuildContext context) {
    final workflows = state.items
        .where(
          (item) => item.isPending || item.isAccepted || item.isActiveStatus,
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        if (workflows.isNotEmpty) ...[
          Text('Requests and active co-host', style: context.pStrong),
          const SizedBox(height: 8),
          ...workflows.map(
            (item) => _CohostWorkflowTile(
              item: item,
              state: state,
              controller: controller,
              hostView: true,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (workflows.isEmpty) ...[
          Text('Eligible active viewers', style: context.pStrong),
          const SizedBox(height: 8),
          if (viewers.isEmpty)
            Text(
              'No eligible authenticated viewers are active in the room.',
              style: AppTextStylesX(context).caption,
            )
          else
            ...viewers.map(
              (viewer) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AppCircularAvatar(
                  name: viewer.displayName,
                  imageUrl: viewer.avatar,
                  radius: 20,
                ),
                title: Text(
                  viewer.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  viewer.accountId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton.filledTonal(
                  tooltip: 'Invite to co-host',
                  onPressed: state.isMutating
                      ? null
                      : () =>
                            unawaited(_invite(context, viewer.livekitIdentity)),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _invite(BuildContext context, String identity) async {
    final invited = await controller.invite(
      liveId: liveId,
      livekitIdentity: identity,
    );
    if (!context.mounted) return;
    if (invited == null) {
      ShowSnack(context, 'Could not invite this viewer.').error();
      return;
    }
    ShowSnack(context, 'Co-host invitation sent.').success();
  }
}

class _ViewerCohostTools extends StatelessWidget {
  const _ViewerCohostTools({
    required this.liveId,
    required this.sessionId,
    required this.canRequest,
    required this.state,
    required this.controller,
  });

  final String liveId;
  final String? sessionId;
  final bool canRequest;
  final LiveCohostState state;
  final LiveCohostController controller;

  @override
  Widget build(BuildContext context) {
    final workflows = state.items
        .where(
          (item) => item.isPending || item.isAccepted || item.isActiveStatus,
        )
        .toList(growable: false);
    final validSessionId = sessionId?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        if (workflows.isNotEmpty)
          ...workflows.map(
            (item) => _CohostWorkflowTile(
              item: item,
              state: state,
              controller: controller,
              hostView: false,
            ),
          )
        else if (canRequest && validSessionId.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isMutating
                  ? null
                  : () => unawaited(_request(context, validSessionId)),
              icon: const Icon(Icons.waving_hand_outlined),
              label: const Text('Request to co-host'),
            ),
          )
        else
          Text(
            'Co-hosting is not currently available for this account.',
            style: AppTextStylesX(context).caption,
          ),
      ],
    );
  }

  Future<void> _request(BuildContext context, String validSessionId) async {
    final requested = await controller.request(
      liveId: liveId,
      sessionId: validSessionId,
    );
    if (!context.mounted) return;
    if (requested == null) {
      ShowSnack(context, 'Could not send the co-host request.').error();
      return;
    }
    ShowSnack(context, 'Co-host request sent.').success();
  }
}

class _CohostWorkflowTile extends StatelessWidget {
  const _CohostWorkflowTile({
    required this.item,
    required this.state,
    required this.controller,
    required this.hostView,
  });

  final LiveCohost item;
  final LiveCohostState state;
  final LiveCohostController controller;
  final bool hostView;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppCircularAvatar(
        name: item.displayName,
        imageUrl: item.avatar,
        radius: 20,
      ),
      title: Text(
        item.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_statusLabel),
      trailing: _actions(context),
    );
  }

  String get _statusLabel {
    if (item.isActiveStatus) return 'Active';
    if (item.isAccepted) return 'Connecting';
    return 'Pending';
  }

  Widget? _actions(BuildContext context) {
    if (item.isActiveStatus) {
      return IconButton(
        tooltip: hostView ? 'Remove co-host' : 'Leave co-hosting',
        onPressed: state.isMutating ? null : () => unawaited(_end(context)),
        icon: const Icon(Icons.person_remove_outlined),
      );
    }
    if (item.isAccepted) {
      return IconButton(
        tooltip: 'Cancel co-hosting',
        onPressed: state.isMutating ? null : () => unawaited(_cancel(context)),
        icon: const Icon(Icons.close_rounded),
      );
    }

    final canRespond =
        (hostView && item.isViewerRequest) || (!hostView && item.isHostInvite);
    if (canRespond) {
      return PopupMenuButton<_CohostAction>(
        enabled: !state.isMutating,
        tooltip: 'Respond to co-host request',
        onSelected: (action) {
          switch (action) {
            case _CohostAction.accept:
              unawaited(_respond(context, true));
              break;
            case _CohostAction.reject:
              unawaited(_respond(context, false));
              break;
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem<_CohostAction>(
            value: _CohostAction.accept,
            child: Text('Accept'),
          ),
          PopupMenuItem<_CohostAction>(
            value: _CohostAction.reject,
            child: Text('Reject'),
          ),
        ],
      );
    }
    return IconButton(
      tooltip: 'Cancel co-host request',
      onPressed: state.isMutating ? null : () => unawaited(_cancel(context)),
      icon: const Icon(Icons.close_rounded),
    );
  }

  Future<void> _respond(BuildContext context, bool accept) async {
    final result = await controller.respond(cohostId: item.id, accept: accept);
    if (!context.mounted || result == null) return;
    ShowSnack(
      context,
      accept ? 'Co-host request accepted.' : 'Co-host request rejected.',
    ).success();
  }

  Future<void> _cancel(BuildContext context) async {
    final result = await controller.cancel(cohostId: item.id);
    if (!context.mounted || result == null) return;
    ShowSnack(context, 'Co-host request cancelled.').success();
  }

  Future<void> _end(BuildContext context) async {
    final ended = await controller.end(cohostId: item.id);
    if (!context.mounted || !ended) return;
    ShowSnack(context, 'Co-host session ended.').success();
  }
}

enum _CohostAction { accept, reject }
