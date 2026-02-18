import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:go_router/go_router.dart';

/// Info card block ("Photography Tips" / "Marketing Tips" / "Ranking Tips")
/// Horizontal, scrollable, sliver-safe
class HomeRankingTipsSection extends StatelessWidget {
  const HomeRankingTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final items = <_TipHeroItem>[
      const _TipHeroItem(
        title: 'Photography tips\nthat sell',
        subtitle: 'Learn',
        icon: Icons.camera_alt_outlined,
        routeName: AppRoutes.nPhotoTips,
      ),
      const _TipHeroItem(
        title: 'Boost your\nmarketing reach',
        subtitle: 'Learn',
        icon: Icons.trending_up,
        routeName: AppRoutes.nMarketTips,
      ),
      const _TipHeroItem(
        title: 'Try all the best\nranking tips',
        subtitle: 'Learn',
        icon: Icons.lightbulb_outline,
        routeName: AppRoutes.nRankTips,
      ),
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return _Card(
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              colors: colors,
              onTap: () => context.pushNamed(item.routeName),
            );
          },
        ),
      ),
    );
  }
}

class _TipHeroItem {
  const _TipHeroItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final AppColorTokens colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
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
        ),
      ),
    );
  }
}
