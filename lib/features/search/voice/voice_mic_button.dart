import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';

class VoiceMicButton extends StatelessWidget {
  const VoiceMicButton({
    super.key,
    required this.listening,
    required this.onTap,
  });

  final bool listening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 88,
        width: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: listening ? colors.primary : colors.surface,
          border: Border.all(color: colors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.black.withOpacity(.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.mic,
          color: listening ? colors.white : colors.primary,
          size: 34,
        ),
      ),
    );
  }
}
