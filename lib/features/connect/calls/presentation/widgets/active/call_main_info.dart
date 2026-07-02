import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/timer_badge.dart';
import 'package:flutter/material.dart';

class CallMainInfo extends StatelessWidget {
  final String participant;
  final String subtitle;
  final String initials;
  final CallState callState;

  const CallMainInfo({
    super.key,
    required this.participant,
    required this.subtitle,
    required this.initials,
    required this.callState,
  });

  @override
  Widget build(BuildContext context) {
    final isActuallyInCall =
        callState.uiPhase == UiCallPhase.inCall && callState.hasActiveRoom;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Avatar(initials: initials, size: 120),
          const SizedBox(height: 16),

          Text(
            participant,
            textAlign: TextAlign.center,
            style: context.p.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 6),

          Text(subtitle, textAlign: TextAlign.center),
          const SizedBox(height: 12),

          if (callState.isUpgradePending) ...[
            const SizedBox(height: 12),
            Text(
              'Waiting for video...',
              style: context.p.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.orange,
              ),
            ),
          ],

          TimerBadge(
            text: isActuallyInCall
                ? _formatDuration(callState.duration)
                : (callState.uiPhase == UiCallPhase.joiningRoom
                      ? 'Connecting...'
                      : 'Calling...'),
            isLive: isActuallyInCall,
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const Avatar({super.key, required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surface,
        border: Border.all(color: colors.primary, width: 4),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: .6),
            blurRadius: 18,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: colors.primary,
            height: 1,
          ),
        ),
      ),
    );
  }
}
