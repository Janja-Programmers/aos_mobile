import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class PrefCard extends StatelessWidget {
  const PrefCard({
    super.key,
    required this.leading,
    required this.title,
    required this.value,
    required this.description,
    required this.onTap,
    this.enabled = true,
    this.readOnlyLabel,
  });

  final IconData leading;
  final String title;
  final String value;
  final String description;
  final VoidCallback onTap;
  final bool enabled;
  final String? readOnlyLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : .74,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(leading, color: colors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.h6.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: context.small.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!enabled && readOnlyLabel != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              readOnlyLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.small.copyWith(
                                color: colors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          const SizedBox(width: 2),
                          Icon(
                            enabled
                                ? Icons.chevron_right
                                : Icons.lock_outline_rounded,
                            size: enabled ? 18 : 16,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.pMuted.copyWith(height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
