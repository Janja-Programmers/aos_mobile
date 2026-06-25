import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/sellers/domain/storefront_analytics.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/analytics_card.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/top_performing_post_tile.dart';
import 'package:africaonlinestores/features/shorts/analytics/data/shorts_analytics_models.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';

class AnalyticsSection extends ConsumerWidget {
  const AnalyticsSection({super.key, required this.analytics});

  final StorefrontAnalytics analytics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsFuture = ref.watch(_myShortsAnalyticsProvider);

    return analyticsFuture.when(
      loading: () =>
          _LocalFallbackAnalytics(analytics: analytics, loading: true),
      error: (_, _) => _LocalFallbackAnalytics(analytics: analytics),
      data: (result) {
        final totals = result.totals;
        final hasBackendData =
            totals.views > 0 ||
            totals.impressions > 0 ||
            totals.likes > 0 ||
            totals.comments > 0 ||
            totals.shares > 0 ||
            totals.saves > 0;

        if (!hasBackendData) {
          return _LocalFallbackAnalytics(analytics: analytics);
        }

        return _BackendAnalyticsView(
          totals: totals,
          topShorts: result.topShorts,
          dateFrom: result.dateFrom,
          dateTo: result.dateTo,
        );
      },
    );
  }
}

final _myShortsAnalyticsProvider = FutureProvider.autoDispose((ref) async {
  final result = await ref
      .read(shortsAnalyticsApiProvider)
      .myAnalytics(limit: 5);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

class _BackendAnalyticsView extends StatelessWidget {
  final ShortsAnalyticsSummary totals;
  final List<ShortsTopItem> topShorts;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const _BackendAnalyticsView({
    required this.totals,
    required this.topShorts,
    this.dateFrom,
    this.dateTo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: context.p.copyWith(fontWeight: FontWeight.w800),
        ),
        if (dateFrom != null && dateTo != null) ...[
          const SizedBox(height: 4),
          Text(
            '${_date(dateFrom!)} — ${_date(dateTo!)}',
            style: context.small.copyWith(color: context.appColors.textMuted),
          ),
        ],
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
              value: _formatCount(totals.views),
              label: 'Views',
            ),
            AnalyticsCard(
              icon: Icons.visibility_outlined,
              value: _formatCount(totals.impressions),
              label: 'Impressions',
            ),
            AnalyticsCard(
              icon: Icons.favorite_border_rounded,
              value: _formatCount(totals.likes),
              label: 'Likes',
            ),
            AnalyticsCard(
              icon: Icons.chat_bubble_outline,
              value: _formatCount(totals.comments),
              label: 'Comments',
            ),
            AnalyticsCard(
              icon: Icons.reply_outlined,
              value: _formatCount(totals.shares),
              label: 'Shares',
            ),
            AnalyticsCard(
              icon: Icons.bookmark_border_rounded,
              value: _formatCount(totals.saves),
              label: 'Saves',
            ),
            AnalyticsCard(
              icon: Icons.download_outlined,
              value: _formatCount(totals.downloads),
              label: 'Downloads',
            ),
            AnalyticsCard(
              icon: Icons.timer_outlined,
              value: _formatWatch(totals.watchTimeMs),
              label: 'Watch time',
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Top Shorts',
          style: context.p.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (topShorts.isEmpty)
          Text('No top shorts yet.', style: context.pMuted)
        else
          ...topShorts.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: context.appColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: context.appColors.primary.withOpacity(.10),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: context.appColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.caption.isEmpty ? item.id : item.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.pStrong,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatCount(item.views)} views',
                    style: context.small,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _date(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  static String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  static String _formatWatch(int ms) {
    final seconds = (ms / 1000).round();
    if (seconds >= 3600) return '${(seconds / 3600).toStringAsFixed(1)}h';
    if (seconds >= 60) return '${(seconds / 60).toStringAsFixed(1)}m';
    return '${seconds}s';
  }
}

class _LocalFallbackAnalytics extends StatelessWidget {
  const _LocalFallbackAnalytics({
    required this.analytics,
    this.loading = false,
  });

  final StorefrontAnalytics analytics;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
