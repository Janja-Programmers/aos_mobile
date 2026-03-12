import 'package:flutter/material.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_models.dart';

class MiniCategoryPanel extends StatelessWidget {
  const MiniCategoryPanel({super.key, required this.items});

  final List<HomeCategoryItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final shown = items.length > 4 ? items.take(4).toList() : items;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.home_you_might_be_looking_for,
            style: context.bodyStrong.copyWith(fontSize: 16, height: 1.2),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = shown[i];

                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: colors.border.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            item.icon,
                            size: 16,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.body,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
