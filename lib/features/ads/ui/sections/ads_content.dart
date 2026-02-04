import 'package:africaonlinestores/features/ads/ui/widgets/ad_card.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

import 'package:africaonlinestores/ui/components/app_bottom_nav.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class AdListContentView extends StatelessWidget {
  const AdListContentView({
    super.key,
    required this.items,
    required this.country,
    required this.onLoadMore,
    required this.onRefresh,
    required this.loadingMore,
    required this.hasMore,
  });

  final List<AOSAdListItem> items;
  final String country;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final bool loadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: NotificationListener<ScrollNotification>(
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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text('Popular Products', style: context.h4),
                      const Spacer(),
                      Text(
                        country,
                        style: context.p.copyWith(
                          color: context.appColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final ad = items[i];
                    return AdCard(
                      ad: ad,
                      onTap: () {
                        context.push(AppRoutes.adDetailsPath(ad.id));
                      },
                    );
                  }, childCount: items.length),
                ),
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
      ),
    );
  }
}
