import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

import 'package:africaonlinestores/features/home/components/home_categories_preview_section.dart';
import 'package:africaonlinestores/features/home/components/home_hero_carousel_section.dart';
import 'package:africaonlinestores/features/home/components/home_popular_ads_section.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';

/// Content body for the Home (Ads list) screen.
///
/// This is a sliver-based scroll view so we can compose the page from small
/// reusable "sections".
class AdListContentView extends ConsumerWidget {
  const AdListContentView({
    super.key,
    required this.items,
    required this.country,
    required this.locationLabel,
    required this.onTapLocation,
    required this.onLoadMore,
    required this.onRefresh,
    required this.loadingMore,
    required this.hasMore,
  });

  final List<AOSAdListItem> items;
  final String country;
  final String locationLabel;
  final VoidCallback onTapLocation;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final bool loadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
          onLoadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: HomeHeroCarouselSection(),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: HomeCategoriesPreviewSection(limit: 10),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 12),
              sliver: HomePopularAdsSection(items: items, country: country),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: loadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : (!hasMore && items.isNotEmpty)
                    ? Text(
                        'No more ads',
                        style: context.p.copyWith(
                          color: context.appColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
