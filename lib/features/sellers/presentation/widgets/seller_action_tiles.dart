import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class ActionTile extends StatelessWidget {
  final Widget leading;
  final Color? iconBackgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;

  const ActionTile({
    super.key,
    required this.leading,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      elevation: 1,
      color: colors.surface,
      shadowColor: colors.border,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: leading,
              ),

              const SizedBox(width: 14),

              // Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Optional badge
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor ?? colors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText!,
                              style: context.p.copyWith(
                                color: colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: context.pMuted.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.chevron_right, color: colors.border),
            ],
          ),
        ),
      ),
    );
  }
}
