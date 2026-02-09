import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

/// Reusable section header: title + optional "See all" action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: context.h5.copyWith(color: colors.primary)),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'See all',
                style: context.p.copyWith(color: colors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
