import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.selected = false,
    this.hasDropdown = false,
  });

  final String label;
  final bool selected;
  final bool hasDropdown;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primaryRedSoft = colors.primary.withOpacity(.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? primaryRedSoft : colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? colors.primary : colors.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: context.p.copyWith(
              color: selected ? colors.primary : colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasDropdown) const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }
}
