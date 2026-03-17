import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class ToolButton extends StatelessWidget {
  const ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? colors.red : colors.border,
                width: 2,
              ),
            ),
            child: Icon(icon),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
