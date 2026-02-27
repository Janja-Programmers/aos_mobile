import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';

const homeAdsSections = <HomeAdsSection>[
  /// 🔥 Flash Sales
  HomeAdsSection(
    key: 'flash_sales',
    title: 'Flash Sales in AOS',
    promotionType: 'flash_sale',
  ),

  /// 💸 Top Deals
  HomeAdsSection(
    key: 'top_deals',
    title: 'Top Deals in AOS',
    promotionType: 'deal',
  ),

  /// 🆕 New Products
  HomeAdsSection(
    key: 'new_products',
    title: 'New Products in AOS',
    sort: 'recent',
  ),

  /// 🏠 Home & Furniture
  HomeAdsSection(
    key: 'home_furniture',
    title: 'Home & Furniture in AOS',
    preferredCategoryNames: ['Home, Furniture & Appliances'],
    seeAllCategoryId: 'Home, Furniture & Appliances',
  ),

  /// 💄 Beauty
  HomeAdsSection(
    key: 'beauty',
    title: 'Beauty',
    preferredCategoryNames: ['Beauty & Personal Care'],
    seeAllCategoryId: 'Beauty & Personal Care',
  ),

  /// 👶 Babies & Kids
  HomeAdsSection(
    key: 'babies',
    title: 'Babies & Kids',
    preferredCategoryNames: ['Babies & Kids'],
    seeAllCategoryId: 'Babies & Kids',
  ),

  /// 👗 Women's Fashion
  HomeAdsSection(
    key: 'womens_fashion',
    title: 'Women\'s Fashion',
    preferredCategoryNames: ['Women\'s Fashion'],
    seeAllCategoryId: 'Women\'s Fashion',
  ),

  /// 💻 Electronics
  HomeAdsSection(
    key: 'electronics',
    title: 'Electronics',
    preferredCategoryNames: ['Electronics'],
    seeAllCategoryId: 'Electronics',
  ),
];
