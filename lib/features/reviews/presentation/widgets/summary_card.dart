import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalReviews,
    required this.averageRating,
    required this.distribution,
  });

  final int totalReviews;
  final double averageRating;
  final Map<int, int> distribution;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final max = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return SectionCard(
      child: Row(
        children: [
          /// LEFT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(averageRating.toStringAsFixed(1), style: context.h3),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) {
                  final starIndex = i + 1;

                  if (averageRating >= starIndex) {
                    return Icon(Icons.star, size: 16, color: colors.amber);
                  } else if (averageRating >= starIndex - 0.5) {
                    return Icon(Icons.star_half, size: 16, color: colors.amber);
                  } else {
                    return Icon(
                      Icons.star_border,
                      size: 16,
                      color: colors.border,
                    );
                  }
                }),
              ),
              const SizedBox(height: 4),
              Text('$totalReviews reviews', style: context.pMuted),
            ],
          ),

          const SizedBox(width: 20),

          /// RIGHT (distribution)
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = distribution[star] ?? 0;

                final value = max == 0 ? 0.0 : count / max;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: context.pMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: colors.surface,
                          color: colors.amber,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('$count', style: context.pMuted),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
