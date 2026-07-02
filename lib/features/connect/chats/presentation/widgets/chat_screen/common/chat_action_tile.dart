import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class ChatActionTile extends StatelessWidget {
  const ChatActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = destructive ? colors.red : colors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: fg),
      title: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
