import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';

/// Reusable section header styled like AOS Flash Sales.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.h5.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'See all',
                  style: context.p.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
