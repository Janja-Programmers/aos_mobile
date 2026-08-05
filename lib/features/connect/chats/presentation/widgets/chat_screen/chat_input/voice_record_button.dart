import 'dart:async';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoiceRecordButton extends StatelessWidget {
  const VoiceRecordButton({
    super.key,
    required this.onStart,
    this.disabled = false,
    this.size = 48,
  });

  final Future<void> Function() onStart;
  final bool disabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      enabled: !disabled,
      label: l10n.chat_voice_tap_to_record,
      child: Tooltip(
        message: l10n.chat_voice_tap_to_record,
        child: InkResponse(
          radius: size / 2 + 4,
          onTap: disabled
              ? null
              : () {
                  unawaited(_startWithFeedback());
                },
          onLongPress: disabled
              ? null
              : () {
                  unawaited(_startWithFeedback());
                },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic_rounded, color: colors.white, size: 23),
          ),
        ),
      ),
    );
  }

  Future<void> _startWithFeedback() async {
    await HapticFeedback.mediumImpact();
    await onStart();
  }
}
