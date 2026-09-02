import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';

const homeAdsSections = <HomeAdsSection>[
  HomeAdsSection(key: 'flash_sales', promotionType: 'flash_sale'),
  HomeAdsSection(key: 'new_products', sort: 'recent'),
  HomeAdsSection(key: 'deal', promotionType: 'deal'),
];

List<HomeAdsSection> buildHomeAdsSections(List<CategoryNode> categories) {
  return List<HomeAdsSection>.unmodifiable(<HomeAdsSection>[
    ...homeAdsSections,
    for (final CategoryNode category in categories)
      HomeAdsSection(
        key: 'category:${category.id}',
        title: category.name,
        categoryId: category.id,
      ),
  ]);
}
