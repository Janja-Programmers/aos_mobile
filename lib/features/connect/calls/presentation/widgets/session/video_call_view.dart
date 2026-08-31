import 'dart:ui' as ui;

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_participant_resolver.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/session/call_control_dock.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class VideoCallView extends StatefulWidget {
  final CallState callState;
  final CallManager manager;
  final ResolvedCallParticipant participant;
  final bool showActiveControls;

  const VideoCallView({
    super.key,
    required this.callState,
    required this.manager,
    required this.participant,
    this.showActiveControls = true,
  });

  @override
  State<VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<VideoCallView> {
  bool _isLocalMain = false;
  Offset? _pipOffset;

  @override
  Widget build(BuildContext context) {
    final localTrack = _localVideoTrack(widget.callState.room);
    final remoteTrack = _remoteVideoTrack(widget.callState.room);
    final hasLocalVideo = localTrack != null;
    final hasRemoteVideo = remoteTrack != null;
    final canSwapCanvases = hasLocalVideo && hasRemoteVideo;

    final mainSlot = _mainSlot(
      localTrack: localTrack,
      remoteTrack: remoteTrack,
    );
    final pipSlot = _pipSlot(localTrack: localTrack, remoteTrack: remoteTrack);

    return Scaffold(
      backgroundColor: const Color(0xFF05080A),
      body: Stack(
        children: [
          Positioned.fill(
            child: _TappableCanvas(
              enabled: canSwapCanvases,
              onTap: _swapCanvases,
              child: _MainVideoCanvas(
                slot: mainSlot,
                participant: widget.participant,
                statusText: _mainPlaceholderText(
                  hasLocalVideo: hasLocalVideo,
                  hasRemoteVideo: hasRemoteVideo,
                ),
              ),
            ),
          ),
          const Positioned.fill(child: _VideoScrim()),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _VideoCallTopBar(
                    name: widget.participant.displayName,
                    statusText: _statusText(context, widget.callState),
                    onMinimize: () => _minimize(context),
                  ),
                ),
                if (pipSlot != null)
                  _DraggablePictureInPicture(
                    offset: _resolvePipOffset(context),
                    onDragUpdate: (delta) => _movePip(context, delta),
                    child: _TappableCanvas(
                      enabled: canSwapCanvases,
                      onTap: _swapCanvases,
                      child: _PictureInPictureCanvas(slot: pipSlot),
                    ),
                  ),
                if (widget.showActiveControls && hasLocalVideo)
                  Positioned(
                    right: 14,
                    top: 86,
                    child: _SwitchCameraButton(
                      canSwitchCamera: widget.callState.isLocalVideoEnabled,
                      onSwitchCamera: widget.manager.switchCamera,
                    ),
                  ),
                if (widget.showActiveControls)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CallControlDock(
                      isMuted: widget.callState.isMuted,
                      isSpeakerOn: widget.callState.isSpeakerOn,
                      isVideoCall:
                          widget.callState.callMediaMode == CallMediaMode.video,
                      isLocalVideoEnabled: widget.callState.isLocalVideoEnabled,
                      isWaitingForVideoUpgradeResponse:
                          widget.callState.isWaitingForVideoUpgradeResponse,
                      hasIncomingVideoUpgradeRequest:
                          widget.callState.hasIncomingVideoUpgradeRequest,
                      showMoreButton: false,
                      onVideo:
                          widget.callState.isWaitingForVideoUpgradeResponse ||
                              widget.callState.hasIncomingVideoUpgradeRequest
                          ? null
                          : widget.manager.toggleVideo,
                      onSpeaker: widget.manager.toggleSpeaker,
                      onMute: widget.manager.toggleMute,
                      onEnd: widget.manager.endCurrentCall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _swapCanvases() {
    setState(() {
      _isLocalMain = !_isLocalMain;
    });
  }

  Offset _resolvePipOffset(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final defaultOffset = Offset(size.width - 130, size.height - 278);

    return _clampPipOffset(_pipOffset ?? defaultOffset, size);
  }

  void _movePip(BuildContext context, Offset delta) {
    final size = MediaQuery.of(context).size;

    setState(() {
      _pipOffset = _clampPipOffset(_resolvePipOffset(context) + delta, size);
    });
  }

  Offset _clampPipOffset(Offset value, Size size) {
    const pipWidth = 116.0;
    const pipHeight = 158.0;
    const margin = 12.0;
    final topSafe = MediaQuery.maybeOf(context)?.padding.top ?? 0;
    final bottomSafe = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;

    final maxX = (size.width - pipWidth - margin)
        .clamp(margin, double.infinity)
        .toDouble();
    final maxY = (size.height - pipHeight - bottomSafe - 92)
        .clamp(topSafe + 88, double.infinity)
        .toDouble();

    return Offset(
      value.dx.clamp(margin, maxX).toDouble(),
      value.dy.clamp(topSafe + 88, maxY).toDouble(),
    );
  }

  _VideoCanvasSlot _mainSlot({
    required LocalVideoTrack? localTrack,
    required RemoteVideoTrack? remoteTrack,
  }) {
    if (_isLocalMain && localTrack != null && remoteTrack != null) {
      return _VideoCanvasSlot.local(localTrack);
    }

    if (remoteTrack != null) {
      return _VideoCanvasSlot.remote(remoteTrack);
    }

    if (_isLocalMain && localTrack != null) {
      return _VideoCanvasSlot.local(localTrack);
    }

    return const _VideoCanvasSlot.placeholder();
  }

  _VideoCanvasSlot? _pipSlot({
    required LocalVideoTrack? localTrack,
    required RemoteVideoTrack? remoteTrack,
  }) {
    if (_isLocalMain && remoteTrack != null) {
      return _VideoCanvasSlot.remote(remoteTrack);
    }

    if (localTrack != null) {
      return _VideoCanvasSlot.local(localTrack);
    }

    return null;
  }

  String _mainPlaceholderText({
    required bool hasLocalVideo,
    required bool hasRemoteVideo,
  }) {
    final l10n = context.l10n;
    if (hasRemoteVideo) return '';
    if (hasLocalVideo) return l10n.chat_waiting_for_video;
    if (!widget.callState.hasActiveRoom) {
      return l10n.chat_waiting_for_connection;
    }
    if (widget.callState.isLocalVideoEnabled) {
      return l10n.chat_camera_starting;
    }
    return l10n.chat_camera_off;
  }

  static void _minimize(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.maybePop();
    }
  }

  static String _statusText(BuildContext context, CallState state) {
    final l10n = context.l10n;
    final isActuallyInCall =
        state.uiPhase == UiCallPhase.inCall && state.hasActiveRoom;

    if (isActuallyInCall) {
      return _formatDuration(state.duration);
    }

    return switch (state.uiPhase) {
      UiCallPhase.outgoingStarting => l10n.chat_calling,
      UiCallPhase.outgoingRinging => l10n.chat_ringing,
      UiCallPhase.joiningRoom => l10n.chat_connecting,
      UiCallPhase.inCall => l10n.chat_connecting,
      UiCallPhase.incomingRinging => l10n.chat_incoming_video_call,
      UiCallPhase.finished => l10n.chat_call_ended,
      UiCallPhase.cancelled => l10n.chat_call_cancelled,
      UiCallPhase.error => l10n.chat_call_failed,
      UiCallPhase.idle => l10n.chat_video_call,
    };
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static LocalVideoTrack? _localVideoTrack(Room? room) {
    if (room == null) return null;

    final publications = room.localParticipant?.videoTrackPublications ?? [];

    for (final pub in publications) {
      final track = pub.track;
      if (track is LocalVideoTrack && !track.muted) {
        return track;
      }
    }

    return null;
  }

  static RemoteVideoTrack? _remoteVideoTrack(Room? room) {
    if (room == null) return null;

    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.videoTrackPublications) {
        final track = pub.track;
        if (track is RemoteVideoTrack && !track.muted) {
          return track;
        }
      }
    }

    return null;
  }
}

enum _VideoCanvasKind { local, remote, placeholder }

class _VideoCanvasSlot {
  final _VideoCanvasKind kind;
  final VideoTrack? track;

  const _VideoCanvasSlot._(this.kind, this.track);

  const _VideoCanvasSlot.local(LocalVideoTrack track)
    : this._(_VideoCanvasKind.local, track);

  const _VideoCanvasSlot.remote(RemoteVideoTrack track)
    : this._(_VideoCanvasKind.remote, track);

  const _VideoCanvasSlot.placeholder()
    : this._(_VideoCanvasKind.placeholder, null);

  bool get isLocal => kind == _VideoCanvasKind.local;
  bool get isPlaceholder => kind == _VideoCanvasKind.placeholder;
}

class _MainVideoCanvas extends StatelessWidget {
  final _VideoCanvasSlot slot;
  final ResolvedCallParticipant participant;
  final String statusText;

  const _MainVideoCanvas({
    required this.slot,
    required this.participant,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    if (!slot.isPlaceholder && slot.track != null) {
      return _TrackRenderer(slot: slot, fit: VideoViewFit.cover);
    }

    return _VideoPlaceholder(
      participant: participant,
      statusText: statusText,
      large: true,
    );
  }
}

class _PictureInPictureCanvas extends StatelessWidget {
  final _VideoCanvasSlot slot;

  const _PictureInPictureCanvas({required this.slot});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 116,
      height: 158,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0B141A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _TrackRenderer(slot: slot, fit: VideoViewFit.cover),
          Positioned(
            right: 8,
            bottom: 8,
            child: Icon(
              slot.isLocal ? Icons.person : Icons.person_outline,
              color: colors.white.withValues(alpha: 0.82),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRenderer extends StatelessWidget {
  final _VideoCanvasSlot slot;
  final VideoViewFit fit;

  const _TrackRenderer({required this.slot, required this.fit});

  @override
  Widget build(BuildContext context) {
    final track = slot.track;

    if (track == null) {
      return const ColoredBox(color: Color(0xFF0B141A));
    }

    return VideoTrackRenderer(
      track,
      fit: fit,
      mirrorMode: slot.isLocal
          ? VideoViewMirrorMode.mirror
          : VideoViewMirrorMode.off,
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final ResolvedCallParticipant participant;
  final String statusText;
  final bool large;

  const _VideoPlaceholder({
    required this.participant,
    required this.statusText,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = large ? 112.0 : 48.0;
    final colors = context.appColors;

    return ColoredBox(
      color: const Color(0xFF0B141A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ParticipantAvatar(participant: participant, size: avatarSize),
            if (large) ...[
              const SizedBox(height: 18),
              Text(
                participant.displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (statusText.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.white.withValues(alpha: 0.72),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  final ResolvedCallParticipant participant;
  final double size;

  const _ParticipantAvatar({required this.participant, required this.size});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = participant.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF263238),
        border: Border.all(color: const Color(0x26FFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? AppNetworkImage(
              url: avatarUrl,
              width: size,
              height: size,
              errorBuilder: (_, _, _) =>
                  _InitialsAvatar(initials: participant.initials, size: size),
            )
          : _InitialsAvatar(initials: participant.initials, size: size),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const _InitialsAvatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: colors.white,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VideoCallTopBar extends StatelessWidget {
  final String name;
  final String statusText;
  final VoidCallback onMinimize;

  const _VideoCallTopBar({
    required this.name,
    required this.statusText,
    required this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Row(
          children: [
            _RoundVideoButton(
              icon: Icons.keyboard_arrow_down_rounded,
              semanticLabel: context.l10n.chat_minimize_call,
              onTap: onMinimize,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 8,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      statusText,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 8,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 48, height: 48),
          ],
        ),
      ),
    );
  }
}

class _SwitchCameraButton extends StatelessWidget {
  final bool canSwitchCamera;
  final VoidCallback onSwitchCamera;

  const _SwitchCameraButton({
    required this.canSwitchCamera,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return _RoundVideoButton(
      icon: Icons.cameraswitch_rounded,
      semanticLabel: context.l10n.chat_switch_camera,
      onTap: canSwitchCamera ? onSwitchCamera : null,
    );
  }
}

class _RoundVideoButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  const _RoundVideoButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: const Color(0x99111A1F),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: enabled ? onTap : null,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  icon,
                  color: enabled ? Colors.white : Colors.white38,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggablePictureInPicture extends StatelessWidget {
  final Offset offset;
  final ValueChanged<Offset> onDragUpdate;
  final Widget child;

  const _DraggablePictureInPicture({
    required this.offset,
    required this.onDragUpdate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) => onDragUpdate(details.delta),
        child: child,
      ),
    );
  }
}

class _TappableCanvas extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  const _TappableCanvas({
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class _VideoScrim extends StatelessWidget {
  const _VideoScrim();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              colors.black.withValues(alpha: 0.48),
              colors.black.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0, 0.56, 1],
          ),
        ),
      ),
    );
  }
}
