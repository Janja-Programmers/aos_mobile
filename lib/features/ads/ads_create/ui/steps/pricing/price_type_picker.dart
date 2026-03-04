import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PriceTypePicker extends StatelessWidget {
  const PriceTypePicker({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final String? selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Type', style: context.pStrong),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < options.length - 1; i++) ...[
                _RowOption(
                  type: options[i],
                  selected: selected == options[i],
                  onTap: () => onChanged(options[i]),
                ),
                if (i != options.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colors.border.withOpacity(0.6),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RowOption extends StatelessWidget {
  const _RowOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final String type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  Text(_title(type), style: context.pStrong),
                  const SizedBox(height: 4),
                  Text(_subtitle(type), style: context.pMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _title(String type) {
    switch (type) {
      case 'Fixed':
        return 'Fixed Price';
      case 'Negotiable':
        return 'Negotiable';
      default:
        return type;
    }
  }

  static String _subtitle(String type) {
    switch (type) {
      case 'Fixed':
        return 'Price is firm and non-negotiable';
      case 'Negotiable':
        return 'Buyers can make offers on this item';
      default:
        return '';
    }
  }
}
