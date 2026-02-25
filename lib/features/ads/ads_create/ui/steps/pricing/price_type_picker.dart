import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PriceTypePicker extends StatelessWidget {
  const PriceTypePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Type', style: context.pStrong),
        const SizedBox(height: 10),

        _OptionTile(
          title: 'Fixed Price',
          subtitle: 'Price is firm and non-negotiable',
          selected: selected == 'Fixed',
          onTap: () => onChanged('Fixed'),
        ),

        const SizedBox(height: 10),

        _OptionTile(
          title: 'Negotiable',
          subtitle: 'Buyers can make offers on this item',
          selected: selected == 'Negotiable',
          onTap: () => onChanged('Negotiable'),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? colors.primary : colors.border,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.pStrong),
                  const SizedBox(height: 2),
                  Text(subtitle, style: context.pMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
