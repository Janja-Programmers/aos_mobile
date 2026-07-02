import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';

const homeAdsSections = <HomeAdsSection>[
  HomeAdsSection(key: 'flash_sales', promotionType: 'flash_sale'),
  HomeAdsSection(key: 'services', preferredCategoryNames: ['Services']),
  HomeAdsSection(key: 'new_products', sort: 'recent'),
  HomeAdsSection(
    key: 'electronic_deal',
    preferredCategoryNames: ['Electronics'],
    promotionType: 'deal',
  ),
  HomeAdsSection(key: 'deal', promotionType: 'deal'),
  HomeAdsSection(
    key: 'furniture',
    preferredCategoryNames: ['Home, Furniture & Appliances'],
  ),
  HomeAdsSection(key: 'electronics', preferredCategoryNames: ['Electronics']),
  HomeAdsSection(key: 'fashion', preferredCategoryNames: ['Men\'s Fashion']),
  HomeAdsSection(key: 'kids', preferredCategoryNames: ['Babies & Kids']),
  HomeAdsSection(
    key: 'beauty',
    preferredCategoryNames: ['Beauty & Personal Care'],
  ),
];
