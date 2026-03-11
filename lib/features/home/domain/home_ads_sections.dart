import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';

const homeAdsSections = <HomeAdsSection>[
  /// 🔥 Flash Sales
  HomeAdsSection(
    key: 'flash_sales',
    title: 'AOS Flash Sales',
    promotionType: 'flash_sale',
    seeAllCategoryId: '',
  ),

  /// 🔥 Services
  HomeAdsSection(
    key: 'services',
    title: 'Services Near You',
    preferredCategoryNames: ['Services'],
    seeAllCategoryId: '',
  ),

  /// 🆕 New Products
  HomeAdsSection(
    key: 'new_products',
    title: 'New Products in AOS',
    sort: 'recent',
    seeAllCategoryId: '',
  ),

  /// 💸 Electronic Deals
  HomeAdsSection(
    key: 'electronic_deal',
    title: 'AOS Electronic Deals',
    preferredCategoryNames: ["Electronics"],
    promotionType: 'deal',
    seeAllCategoryId: '',
  ),

  /// 💸 Top Deals
  HomeAdsSection(
    key: 'deal',
    title: 'AOS Deals',
    promotionType: 'deal',
    seeAllCategoryId: '',
  ),

  /// 🏠 Home & Furniture
  HomeAdsSection(
    key: 'furniture',
    title: 'Furniture',
    preferredCategoryNames: ['Home, Furniture & Appliances'],
    seeAllCategoryId: 'Home, Furniture & Appliances',
  ),

  /// 💸 Electronics
  HomeAdsSection(
    key: 'electronics',
    title: 'Electronics',
    preferredCategoryNames: ["Electronics"],
    seeAllCategoryId: '',
  ),

  /// 👗 Fashion
  HomeAdsSection(
    key: 'fashion',
    title: 'Fashion',
    preferredCategoryNames: ['Women\'s Fashion', 'Men\'s Fashion'],
    seeAllCategoryId: 'Women\'s Fashion',
  ),

  /// 👶 Babies & Kids
  HomeAdsSection(
    key: 'kids',
    title: 'Babies & Kids',
    preferredCategoryNames: ['Babies & Kids'],
    seeAllCategoryId: 'Babies & Kids',
  ),

  /// 💄 Beauty
  HomeAdsSection(
    key: 'beauty',
    title: 'Beauty',
    preferredCategoryNames: ['Beauty & Personal Care'],
    seeAllCategoryId: 'Beauty & Personal Care',
  ),
];
