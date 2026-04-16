import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';

class CallControls extends StatelessWidget {
  final CallState callState;
  final CallManager manager;

  const CallControls({
    super.key,
    required this.callState,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final isVideoCall = callState.callMediaMode == CallMediaMode.video;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        children: [
          ActionButton(
            icon: callState.isMuted ? Icons.mic_off : Icons.mic,
            label: callState.isMuted ? 'Unmute' : 'Mute',
            active: callState.isMuted,
            onTap: manager.toggleMute,
          ),

          ActionButton(
            icon: callState.isUpgradePending
                ? Icons
                      .hourglass_top // 🔥 waiting state
                : callState.isLocalVideoEnabled
                ? Icons.videocam
                : Icons.videocam_off,
            label: callState.isUpgradePending ? 'Requesting...' : 'Video',
            active: isVideoCall && callState.isLocalVideoEnabled,
            onTap: callState.isUpgradePending
                ? () {}
                : () => manager.toggleVideo(),
          ),

          ActionButton(
            icon: callState.isSpeakerOn
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined,
            label: 'Speaker',
            active: callState.isSpeakerOn,
            onTap: manager.toggleSpeaker,
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    this.size = 60,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final bg = active ? colors.black : colors.white;
    final fg = active ? colors.white : colors.black;

    return SizedBox(
      width: size + 14,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: bg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? colors.black : colors.border,
                  ),
                ),
                child: Icon(icon, size: size * 0.38, color: fg),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.p.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
