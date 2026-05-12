import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/utils/format_time.dart';

class PresenceLabel extends StatelessWidget {
  const PresenceLabel({
    super.key,
    required this.isTyping,
    required this.isOnline,
    this.lastSeen,
  });

  final bool isTyping;
  final bool isOnline;
  final DateTime? lastSeen;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final text = isTyping
        ? 'Typing...'
        : isOnline
        ? 'Online'
        : lastSeen != null
        ? 'Last seen ${formatTime(lastSeen!)}'
        : null;

    if (text == null) return const SizedBox.shrink();

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.p.copyWith(
        fontSize: 12,
        color: isTyping || isOnline ? colors.success : colors.textMuted,
        fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}
