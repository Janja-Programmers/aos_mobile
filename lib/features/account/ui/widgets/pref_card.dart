import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class PrefCard extends StatelessWidget {
  const PrefCard({
    super.key,
    required this.leading,
    required this.title,
    required this.value,
    required this.description,
    required this.onTap,
    this.leadingColor,
    this.titleColor,
    this.showChevron = true,
  });

  final IconData leading;
  final String title;
  final String value;
  final String description;
  final VoidCallback? onTap;

  final Color? leadingColor;
  final Color? titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (leadingColor ?? scheme.primary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(leading, color: leadingColor ?? scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: context.pStrong)),
                        if (showChevron)
                          Icon(Icons.chevron_right, color: colors.textMuted),
                      ],
                    ),
                    if (value.isNotEmpty) ...[Text(value, style: context.p)],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(description, style: context.pMuted),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
