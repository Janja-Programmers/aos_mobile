import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wishlist state does not perform an eager list request or local cache', () {
    final source = _readSource(
      'lib/features/wishlist/controller/wishlist_controller.dart',
    );

    expect(source, isNot(contains('listWishlist(')));
    expect(source, isNot(contains('WishlistStorage')));
    expect(source, contains('NotifierProvider<WishlistController'));
  });

  test('wishlist API uses exact backend field names', () {
    final source = _readSource('lib/features/ads/data/ads_api.dart');
    final method = source
        .split('Future<Either<Failure, Map<String, dynamic>>> listWishlist({')[1]
        .split('Future<Either<Failure, Map<String, dynamic>>> toggleWishlist')[0];

    expect(method, contains("'q': cleanQuery"));
    expect(method, contains("'verified_seller'"));
    expect(method, isNot(contains("'search'")));
    expect(method, isNot(contains("'verified_sellers'")));
    expect(method, isNot(contains("'preferred_store'")));
  });

  test('wishlist mutation requests an explicit desired state', () {
    final source = _readSource('lib/features/ads/data/ads_api.dart');
    final method = source
        .split('Future<Either<Failure, Map<String, dynamic>>> toggleWishlist({')[1]
        .split('\n  }\n}')[0];

    expect(method, contains('required bool wishlisted'));
    expect(method, contains("'wishlisted': _binaryFlag(wishlisted)"));
  });

  test('unsupported preferred-store filter is not exposed', () {
    final source = _readSource(
      'lib/features/ads/ads_all/presentation/screens/all_ads_screen.dart',
    );

    expect(source, isNot(contains('Preferred Store')));
    expect(source, isNot(contains('preferredStore')));
  });

  test('denied notification permission is logged as an expected state', () {
    final source = _readSource(
      'lib/features/notifications/application/services/'
      'push_notification_service.dart',
    );

    expect(source, contains('appLogger.i('));
    expect(
      source,
      contains(
        '🔕 Notifications are disabled. Push token registration is deferred.',
      ),
    );
    expect(
      source,
      isNot(contains('Notifications permission not granted')),
    );
  });
}

String _readSource(String path) {
  return File(path).readAsStringSync().replaceAll('\r\n', '\n');
}
