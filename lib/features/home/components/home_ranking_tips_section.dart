import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

/// Info card block ("Ranking Tips" / "Boost Marketing")
/// Horizontal, scrollable, sliver-safe
class HomeRankingTipsSection extends StatelessWidget {
  const HomeRankingTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return _Card(
              title: 'Try all the best\nRanking tips',
              subtitle: 'Learn',
              icon: Icons.lightbulb_outline,
              colors: context.appColors,
            );
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // wide hero card
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── Left content ─────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.h5,
                  ),
                  const SizedBox(height: 12),

                  // CTA chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subtitle,
                      style: context.pStrong.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ───────── Right icon ─────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 32, color: colors.warning),
            ),
          ],
        ),
      ),
    );
  }
}
