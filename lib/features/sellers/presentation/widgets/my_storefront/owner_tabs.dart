import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class OwnerTabs extends StatelessWidget {
  const OwnerTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _OwnerTabButton(
            label: 'My Posts',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _OwnerTabButton(
            label: 'Analytics',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _OwnerTabButton extends StatelessWidget {
  const _OwnerTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: context.p.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? colors.white : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
