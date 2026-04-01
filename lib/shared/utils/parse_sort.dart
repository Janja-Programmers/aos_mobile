import 'package:africaonlinestores/shared/enums/ads_sort.dart';

AdsSort? parseSort(String? value) {
  switch (value) {
    case 'rating_high':
      return AdsSort.ratingHigh;
    case 'price_low':
      return AdsSort.priceLow;
    case 'price_high':
      return AdsSort.priceHigh;
    case 'recent':
      return AdsSort.recent;
    default:
      return null;
  }
}
