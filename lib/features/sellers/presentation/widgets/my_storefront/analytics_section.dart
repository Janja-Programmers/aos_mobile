import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/sellers/domain/storefront_analytics.dart';

import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/analytics_card.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/top_performing_post_tile.dart';

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key, required this.analytics});

  final StorefrontAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (analytics.topPosts.isEmpty &&
        analytics.totalViews == 0 &&
        analytics.totalLikes == 0 &&
        analytics.totalComments == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 44, color: colors.primary),
            const SizedBox(height: 10),
            Text('No analytics yet', style: context.p),
            const SizedBox(height: 4),
            Text(
              'Analytics will appear once your posts start getting activity.',
              style: context.small,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: context.p.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            AnalyticsCard(
              icon: Icons.remove_red_eye_outlined,
              value: _formatCount(analytics.totalViews),
              label: 'Total Views',
            ),
            AnalyticsCard(
              icon: Icons.favorite_border_rounded,
              value: _formatCount(analytics.totalLikes),
              label: 'Total Likes',
            ),
            AnalyticsCard(
              icon: Icons.chat_bubble_outline,
              value: _formatCount(analytics.totalComments),
              label: 'Comments',
            ),
            AnalyticsCard(
              icon: Icons.visibility_outlined,
              value: _formatCount(analytics.totalImpressions),
              label: 'Impressions',
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Top Performing Posts',
          style: context.p.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...analytics.topPosts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TopPerformingPostTile(post: post),
          ),
        ),
      ],
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}
