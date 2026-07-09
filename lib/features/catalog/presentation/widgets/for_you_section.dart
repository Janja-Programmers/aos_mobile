import 'package:africaonlinestores/core/routing/helpers/navigation.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/presentation/widgets/for_you_ads_section_box.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

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
    return ForYouAdsSectionBox(
      title: 'For you',
      items: items,
      onSeeAll: () => openAllAds(context, categoryId: categoryId),
    );
  }
}
