import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('draft read uses canonical backend endpoint', () {
    final endpoints = File(
      'lib/core/api/api_endpoints.dart',
    ).readAsStringSync();

    expect(endpoints, contains('getMyAdDraftEndpoint'));
    final api = File('lib/features/ads/data/ads_api.dart').readAsStringSync();
    expect(api, contains('getMyAdDraft({'));
    expect(api, contains('ApiEndpoints.getMyAdDraftEndpoint'));
    expect(endpoints, contains('aos.api.v1.ads.get_my_ad_draft'));
    expect(endpoints, isNot(contains('aos.api.v1.ads.get_ad_draft')));
  });

  test('draft list sends only backend-supported pagination parameters', () {
    final api = File('lib/features/ads/data/ads_api.dart').readAsStringSync();
    final section = api
        .split('Future<Either<Failure, Map<String, dynamic>>> listAdDrafts')[1]
        .split('Future<Either<Failure, Map<String, dynamic>>> myAds')[0];

    expect(section, contains("'limit': limit"));
    expect(section, contains("'offset': offset"));
    expect(section, isNot(contains('marketContext: true')));
    for (final unsupported in <String>[
      'locationId',
      'q',
      'sort',
      'categoryId',
      'promotionType',
      'priceType',
      'priceMin',
      'priceMax',
      'ratingMin',
    ]) {
      expect(section, isNot(contains(unsupported)));
    }
  });

  test('draft and status mutations use POST bodies', () {
    final api = File('lib/features/ads/data/ads_api.dart').readAsStringSync();

    expect(api, contains("data: {'draft_id': draftId}"));
    expect(api, contains("data: {'ad_id': adId, 'action': action}"));
  });
}
