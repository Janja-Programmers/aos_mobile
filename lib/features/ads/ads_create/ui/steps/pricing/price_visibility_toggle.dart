import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';

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
    final isContact = isContactForPrice(priceType);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.border.withOpacity(0.3),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
