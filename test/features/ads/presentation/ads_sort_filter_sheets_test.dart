import 'package:africaonlinestores/features/ads/ads_all/presentation/widgets/ads_sort_filter_sheets.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared sort labels map only to canonical AdsSort values', () {
    expect(adsSortLabel(null), 'Best Match');
    expect(adsSortLabel(AdsSort.recent), 'Newest First');
    expect(adsSortLabel(AdsSort.ratingHigh), 'Top Rated');
    expect(adsSortLabel(AdsSort.priceLow), 'Price: Low to High');
    expect(adsSortLabel(AdsSort.priceHigh), 'Price: High to Low');
  });
}
