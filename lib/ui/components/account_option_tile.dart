import 'package:flutter/material.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class AccountOptionTile extends StatelessWidget {
  const AccountOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _LeadingIcon(icon: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.p),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(subtitle!, style: context.pMuted),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: scheme.onSurface.withOpacity(0.45),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withOpacity(0.22),
            ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: scheme.onSurface.withOpacity(0.75)),
    );
  }
}
