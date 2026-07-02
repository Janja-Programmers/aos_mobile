import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

class CallControlDock extends StatelessWidget {
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoCall;
  final bool isLocalVideoEnabled;
  final bool isWaitingForVideoUpgradeResponse;
  final bool hasIncomingVideoUpgradeRequest;
  final bool showVideoButton;
  final bool showSpeakerButton;
  final bool showMuteButton;
  final bool showMoreButton;
  final bool showEndButton;
  final VoidCallback? onMore;
  final VoidCallback? onVideo;
  final VoidCallback? onSpeaker;
  final VoidCallback? onMute;
  final VoidCallback? onEnd;

  const CallControlDock({
    super.key,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isVideoCall,
    required this.isLocalVideoEnabled,
    this.isWaitingForVideoUpgradeResponse = false,
    this.hasIncomingVideoUpgradeRequest = false,
    this.showVideoButton = true,
    this.showSpeakerButton = true,
    this.showMuteButton = true,
    this.showMoreButton = true,
    this.showEndButton = true,
    this.onMore,
    this.onVideo,
    this.onSpeaker,
    this.onMute,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final actions = <Widget>[
      if (showMoreButton)
        _DockButton(
          icon: Icons.more_horiz,
          semanticLabel: 'More call options',
          onTap: onMore,
        ),
      if (showVideoButton)
        _DockButton(
          icon: _videoIcon,
          semanticLabel: _videoLabel,
          isActive: isVideoCall && isLocalVideoEnabled,
          isDisabled:
              isWaitingForVideoUpgradeResponse ||
              hasIncomingVideoUpgradeRequest ||
              onVideo == null,
          onTap: onVideo,
        ),
      if (showSpeakerButton)
        _DockButton(
          icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
          semanticLabel: isSpeakerOn ? 'Turn speaker off' : 'Turn speaker on',
          isActive: isSpeakerOn,
          onTap: onSpeaker,
        ),
      if (showMuteButton)
        _DockButton(
          icon: isMuted ? Icons.mic_off : Icons.mic_off_outlined,
          semanticLabel: isMuted ? 'Unmute microphone' : 'Mute microphone',
          isActive: isMuted,
          activeIconColor: colors.primary,
          onTap: onMute,
        ),
      if (showEndButton)
        _DockButton(
          icon: Icons.call_end,
          semanticLabel: 'End call',
          isDestructive: true,
          onTap: onEnd,
        ),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xE6111A1F),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x1AFFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                if (index > 0) const SizedBox(width: 10),
                actions[index],
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _videoIcon {
    if (isWaitingForVideoUpgradeResponse) return Icons.hourglass_top;
    if (hasIncomingVideoUpgradeRequest) return Icons.video_call_outlined;
    return isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off;
  }

  String get _videoLabel {
    if (isWaitingForVideoUpgradeResponse) return 'Video request pending';
    if (hasIncomingVideoUpgradeRequest) return 'Respond to video request';
    if (isVideoCall && isLocalVideoEnabled) return 'Turn camera off';
    if (isVideoCall) return 'Turn camera on';
    return 'Switch to video call';
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final bool isActive;
  final bool isDestructive;
  final bool isDisabled;
  final Color? activeIconColor;
  final VoidCallback? onTap;

  const _DockButton({
    required this.icon,
    required this.semanticLabel,
    this.isActive = false,
    this.isDestructive = false,
    this.isDisabled = false,
    this.activeIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !isDisabled && onTap != null;
    final backgroundColor = _backgroundColor(enabled);
    final iconColor = _iconColor(enabled);

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: iconColor, size: 25),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(bool enabled) {
    if (isDestructive) return const Color(0xFFE91E4D);
    if (isActive) return Colors.white;
    if (!enabled) return const Color(0xFF263238).withValues(alpha: 0.55);
    return const Color(0xFF1E2A30);
  }

  Color _iconColor(bool enabled) {
    if (isDestructive) return Colors.white;
    if (isActive) return activeIconColor ?? Colors.black;
    if (!enabled) return Colors.white.withValues(alpha: 0.38);
    return Colors.white;
  }
}
