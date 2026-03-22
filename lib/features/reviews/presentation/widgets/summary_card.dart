import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.totalReviews});

  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SectionCard(
      child: Row(
        children: [
          /// LEFT: SCORE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('4.5', style: context.h3),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(Icons.star, size: 16, color: colors.amber),
                ),
              ),
              const SizedBox(height: 4),
              Text('$totalReviews reviews', style: context.pMuted),
            ],
          ),

          const SizedBox(width: 20),

          /// RIGHT: BARS
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: context.pMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: star == 5 ? 1 : 0.4,
                          minHeight: 6,
                          backgroundColor: colors.surface,
                          color: colors.amber,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('3', style: context.pMuted),
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
