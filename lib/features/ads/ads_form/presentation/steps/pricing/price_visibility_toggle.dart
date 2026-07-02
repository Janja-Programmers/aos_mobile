import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

enum PriceVisibility { specify, contact }

class PriceVisibilityToggle extends StatelessWidget {
  const PriceVisibilityToggle({
    super.key,
    required this.priceType,
    required this.onSpecify,
    required this.onContact,
  });

  final String? priceType;
  final VoidCallback onSpecify;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final isContact = priceType == 'Contact for price';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(
              label: 'Specify price',
              selected: !isContact,
              onTap: onSpecify,
              colors: colors,
            ),
          ),
          Expanded(
            child: _segment(
              label: 'Contact for price',
              selected: isContact,
              onTap: onContact,
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required AppColorTokens colors,
  }) {
    final IconData icon = label == 'Specify price'
        ? Icons.local_offer_outlined
        : Icons.messenger_outline_sharp;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.2)
              : colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? colors.primary : colors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.primary : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
