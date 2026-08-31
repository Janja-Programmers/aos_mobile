import 'dart:math' as math;

import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_participant_resolver.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/session/call_control_dock.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/session/incoming_call_action_bar.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class AudioCallView extends StatelessWidget {
  final CallState callState;
  final CallManager manager;
  final ResolvedCallParticipant participant;
  final bool showIncomingActions;

  const AudioCallView({
    super.key,
    required this.callState,
    required this.manager,
    required this.participant,
    this.showIncomingActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActuallyInCall =
        callState.uiPhase == UiCallPhase.inCall && callState.hasActiveRoom;
    final isOutgoingRinging =
        callState.uiPhase == UiCallPhase.outgoingStarting ||
        callState.uiPhase == UiCallPhase.outgoingRinging;

    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      body: Stack(
        children: [
          const Positioned.fill(child: _AudioCallBackground()),
          SafeArea(
            child: Column(
              children: [
                _AudioCallTopBar(
                  name: participant.displayName,
                  statusText: _statusText(context, callState),
                  onMinimize: () => _minimize(context),
                ),
                Expanded(
                  child: _AudioCallBody(
                    participant: participant,
                    showCallingPulse: isOutgoingRinging,
                    showUpgradeWaiting:
                        callState.isWaitingForVideoUpgradeResponse,
                  ),
                ),
                _VideoUpgradePrompt(callState: callState, manager: manager),
                if (showIncomingActions)
                  IncomingCallActionBar(
                    onDecline: manager.rejectIncomingCall,
                    onAnswer: manager.acceptIncomingCall,
                  )
                else
                  CallControlDock(
                    isMuted: callState.isMuted,
                    isSpeakerOn: callState.isSpeakerOn,
                    isVideoCall: false,
                    isLocalVideoEnabled: false,
                    isWaitingForVideoUpgradeResponse:
                        callState.isWaitingForVideoUpgradeResponse,
                    hasIncomingVideoUpgradeRequest:
                        callState.hasIncomingVideoUpgradeRequest,
                    showMoreButton: false,
                    onVideo:
                        isActuallyInCall &&
                            !callState.isWaitingForVideoUpgradeResponse &&
                            !callState.hasIncomingVideoUpgradeRequest
                        ? manager.toggleVideo
                        : null,
                    onSpeaker: manager.toggleSpeaker,
                    onMute: manager.toggleMute,
                    onEnd: manager.endCurrentCall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
      UiCallPhase.incomingRinging =>
        state.callMediaMode == CallMediaMode.video
            ? l10n.chat_incoming_video_call
            : l10n.chat_incoming_voice_call,
      UiCallPhase.finished => l10n.chat_call_ended,
      UiCallPhase.cancelled => l10n.chat_call_cancelled,
      UiCallPhase.error => l10n.chat_call_failed,
      UiCallPhase.idle => l10n.chat_audio_call,
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
}

class _AudioCallTopBar extends StatelessWidget {
  final String name;
  final String statusText;
  final VoidCallback onMinimize;

  const _AudioCallTopBar({
    required this.name,
    required this.statusText,
    required this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 78),
        child: Row(
          children: [
            _TopCircleButton(
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
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

class _AudioCallBody extends StatelessWidget {
  final ResolvedCallParticipant participant;
  final bool showCallingPulse;
  final bool showUpgradeWaiting;

  const _AudioCallBody({
    required this.participant,
    required this.showCallingPulse,
    required this.showUpgradeWaiting,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AudioAvatar(
            initials: participant.initials,
            avatarUrl: participant.avatarUrl,
            pulse: showCallingPulse,
          ),
          if (showUpgradeWaiting) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xCC111A1F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Text(
                context.l10n.chat_waiting_for_video,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AudioAvatar extends StatelessWidget {
  final String initials;
  final String? avatarUrl;
  final bool pulse;

  const _AudioAvatar({
    required this.initials,
    required this.avatarUrl,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    const size = 164.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: pulse ? 1 : 0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final spread = pulse ? (10 + (math.sin(value * math.pi) * 10)) : 0.0;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF25D366,
                ).withValues(alpha: pulse ? 0.22 : 0.10),
                blurRadius: 28 + spread,
                spreadRadius: spread,
              ),
              const BoxShadow(
                color: Color(0x99000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipOval(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF243137), Color(0xFF101A1F)],
            ),
          ),
          child: _AvatarContent(initials: initials, avatarUrl: avatarUrl),
        ),
      ),
    );
  }
}

class _AvatarContent extends StatelessWidget {
  final String initials;
  final String? avatarUrl;

  const _AvatarContent({required this.initials, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return AppNetworkImage(
        url: url,
        errorBuilder: (_, _, _) => _InitialsAvatar(initials: initials),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _InitialsAvatar(initials: initials);
        },
      );
    }

    return _InitialsAvatar(initials: initials);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 58,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _VideoUpgradePrompt extends StatelessWidget {
  final CallState callState;
  final CallManager manager;

  const _VideoUpgradePrompt({required this.callState, required this.manager});

  @override
  Widget build(BuildContext context) {
    if (callState.hasIncomingVideoUpgradeRequest) {
      return _UpgradeCard(
        title: context.l10n.chat_switch_to_video_call,
        message: null,
        primaryLabel: context.l10n.chat_switch_to_video,
        secondaryLabel: context.l10n.chat_cancel,
        onPrimary: manager.acceptVideoUpgrade,
        onSecondary: manager.declineVideoUpgrade,
        errorMessage: callState.videoUpgradeErrorMessage,
      );
    }

    if (callState.videoUpgradeErrorMessage != null) {
      return _UpgradeCard(
        title: context.l10n.chat_video_upgrade_failed,
        message: callState.videoUpgradeErrorMessage,
        primaryLabel: null,
        secondaryLabel: null,
        onPrimary: null,
        onSecondary: null,
        errorMessage: null,
      );
    }

    return const SizedBox.shrink();
  }
}

class _UpgradeCard extends StatelessWidget {
  final String title;
  final String? message;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String? errorMessage;

  const _UpgradeCard({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Align(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 330),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          decoration: BoxDecoration(
            color: const Color(0xF2151C20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x1AFFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x88000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                  ),
                ),
              ],
              if (primaryLabel != null && secondaryLabel != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onSecondary,
                      child: Text(
                        secondaryLabel!,
                        style: const TextStyle(color: Color(0xFF25D366)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    TextButton(
                      onPressed: onPrimary,
                      child: Text(
                        primaryLabel!,
                        style: const TextStyle(color: Color(0xFF25D366)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const _TopCircleButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: const Color(0x66111A1F),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _AudioCallBackground extends StatelessWidget {
  const _AudioCallBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111B21), Color(0xFF071014)],
        ),
      ),
      child: CustomPaint(painter: _WallpaperPatternPainter()),
    );
  }
}

class _WallpaperPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const gap = 42.0;
    for (var y = 0.0; y < size.height + gap; y += gap) {
      for (var x = 0.0; x < size.width + gap; x += gap) {
        canvas.drawCircle(Offset(x, y), 7, paint);
        canvas.drawLine(Offset(x + 14, y + 8), Offset(x + 24, y + 18), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
