import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class VoiceRecordOverlay extends StatelessWidget {
  const VoiceRecordOverlay({
    super.key,
    required this.isCanceling,
    required this.isLocked,
    required this.durationText,
  });

  final bool isCanceling;
  final bool isLocked;
  final String durationText;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final instruction = isCanceling
        ? l10n.chat_voice_release_cancel
        : isLocked
        ? l10n.chat_voice_recording_locked
        : l10n.chat_voice_slide_cancel;

    return Semantics(
      liveRegion: true,
      label: l10n.chat_voice_recording_status(durationText, instruction),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCanceling ? colors.red : colors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCanceling ? Icons.delete_outline_rounded : Icons.mic_rounded,
              color: isCanceling ? colors.red : colors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              durationText,
              style: context.pStrong.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                instruction,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: context.small.copyWith(
                  color: isCanceling ? colors.red : colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
