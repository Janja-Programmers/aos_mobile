import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/navigation.dart';

import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/horizontal_ads_section.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';

class ForYouSection extends ConsumerWidget {
  const ForYouSection({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAds = ref.watch(forYouAdsProvider(categoryId));

    return asyncAds.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return _ForYouContent(categoryId: categoryId, items: items);
      },
    );
  }
}

class _ForYouContent extends StatelessWidget {
  const _ForYouContent({required this.categoryId, required this.items});

  final String categoryId;
  final List<AOSAdListItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: HorizontalAdsSectionBox(
        title: 'For you',
        items: items,
        onSeeAll: () => openAllAds(context, categoryId: categoryId),
      ),
    );
  }
}
