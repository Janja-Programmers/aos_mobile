import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';

/// Home "rails" configuration.
///
/// NOTE: category matching is done by name (case-insensitive) against the
/// catalog tree. If you prefer stable ids, replace `preferredCategoryNames`
/// with explicit ids once your catalog data is finalized.
const homeAdsSections = <HomeAdsSection>[
  HomeAdsSection(
    key: 'flash_sales',
    title: 'Flash Sales',
    preferredCategoryNames: ['Electronics'],
  ),
  HomeAdsSection(key: 'new_products', title: 'New Products', sort: 'recent'),

  HomeAdsSection(key: 'deals', title: 'Deals', sort: 'recent'),

  HomeAdsSection(
    key: 'home_accessories',
    title: 'Home Accessories',
    preferredCategoryNames: <String>[
      'Home Accessories',
      'Home & Garden',
      'Home and Garden',
    ],
  ),
  HomeAdsSection(
    key: 'health_beauty',
    title: 'Health & Beauty',
    preferredCategoryNames: <String>['Health & Beauty', 'Health and Beauty'],
  ),
  HomeAdsSection(
    key: 'baby_kids',
    title: 'Baby & Kids',
    preferredCategoryNames: <String>[
      'Baby & Kids',
      'Baby and Kids',
      'Baby & Children',
    ],
  ),
  HomeAdsSection(
    key: 'laptops_and_computers',
    title: 'Electronics',
    preferredCategoryNames: <String>['Electronics'],
  ),
];
