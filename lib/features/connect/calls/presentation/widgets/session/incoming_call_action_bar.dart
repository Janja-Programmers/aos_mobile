import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

/// Accessible, localization-safe Answer/Decline controls shared by foreground
/// Android audio and video incoming-call surfaces.
class IncomingCallActionBar extends StatelessWidget {
  final VoidCallback onDecline;
  final VoidCallback onAnswer;
  final bool answerWithVideo;

  const IncomingCallActionBar({
    super.key,
    required this.onDecline,
    required this.onAnswer,
    this.answerWithVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _IncomingCallActionButton(
              icon: Icons.call_end_rounded,
              label: l10n.chat_decline_call,
              color: colors.primary,
              onTap: onDecline,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _IncomingCallActionButton(
              icon: answerWithVideo
                  ? Icons.videocam_rounded
                  : Icons.call_rounded,
              label: l10n.chat_answer_call,
              color: colors.success,
              onTap: onAnswer,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingCallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _IncomingCallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: color,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: Icon(icon, color: colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.p.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
