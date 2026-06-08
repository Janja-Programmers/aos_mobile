import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class InputIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const InputIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 42,
        child: Icon(icon, size: 22, color: colors.textMuted),
      ),
    );
  }
}
