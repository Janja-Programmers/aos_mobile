import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class TypingIndicator extends StatelessWidget {
  final bool isTyping;

  const TypingIndicator({super.key, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    if (!isTyping) return const SizedBox.shrink();
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        "Typing...",
        style: context.p.copyWith(fontSize: 14, color: colors.success),
      ),
    );
  }
}
