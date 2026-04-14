import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, color: colors.primary),
          const SizedBox(width: 8),

          // placeholder for waveform animation
          const SizedBox(
            width: 36,
            child: LinearProgressIndicator(minHeight: 4),
          ),

          const SizedBox(width: 12),
          Text(durationText, style: context.p.copyWith(color: colors.white)),
          const SizedBox(width: 12),
          Text(
            isCanceling
                ? 'Release to cancel'
                : isLocked
                ? 'Locked'
                : 'Slide to cancel',
            style: context.p.copyWith(color: colors.white),
          ),
        ],
      ),
    );
  }
}
