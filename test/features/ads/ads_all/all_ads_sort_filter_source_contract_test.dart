import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('All Ads reuses the existing sort and filter toolbar', () {
    final source = File(
      'lib/features/ads/ads_all/presentation/screens/all_ads_screen.dart',
    ).readAsStringSync();

    expect(source, contains('child: _AdsToolbar('));
    expect(source, contains('showAdsSortSheet('));
    expect(source, contains('onChanged: controller.setSortType'));
    expect(source, contains('showAdsFilterSheet('));
    expect(source, contains('onApply: controller.applyFilters'));
    expect(source, contains('showVerifiedSellerFilter: isWishlist'));
    expect(
      source,
      isNot(contains('if (isWishlist)\n              SliverPersistentHeader')),
    );
  });
}
