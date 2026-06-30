import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class FloatingMapButton extends StatelessWidget {
  const FloatingMapButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      elevation: 6,
      color: colors.surface,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: colors.primary),
        onPressed: onTap,
      ),
    );
  }
}
