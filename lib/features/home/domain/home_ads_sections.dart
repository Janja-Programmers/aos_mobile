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
    seeAllCategoryId: 'Electronics',
  ),
  HomeAdsSection(
    key: 'new_products',
    title: 'New Products',
    sort: 'recent',
    seeAllCategoryId: '',
  ),

  HomeAdsSection(
    key: 'deals',
    title: 'Deals',
    sort: 'recent',
    seeAllCategoryId: '',
  ),

  HomeAdsSection(
    key: 'home_accessories',
    title: 'Home Accessories',
    preferredCategoryNames: <String>['Home Accessories'],
    seeAllCategoryId: 'Home Accessories',
  ),
  HomeAdsSection(
    key: 'health_beauty',
    title: 'Health & Beauty',
    preferredCategoryNames: <String>['Hair Beauty', 'Health and Beauty'],
    seeAllCategoryId: 'Hair Beauty',
  ),
  HomeAdsSection(
    key: 'baby_kids',
    title: 'Baby & Kids',
    preferredCategoryNames: ['Babies & Kids'],
    seeAllCategoryId: 'Babies & Kids',
  ),
  HomeAdsSection(
    key: 'fashion',
    title: 'Fashion',
    preferredCategoryNames: ['Women\'s Fashion'],
    seeAllCategoryId: 'Women\'s Fashion',
  ),
  HomeAdsSection(
    key: 'laptops_and_computers',
    title: 'Electronics',
    preferredCategoryNames: <String>['Electronics'],
    seeAllCategoryId: 'Electronics',
  ),
  HomeAdsSection(
    key: 'furniture',
    title: 'Furniture',
    preferredCategoryNames: <String>['Furniture'],
    seeAllCategoryId: 'Furniture',
  ),
];
