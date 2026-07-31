import 'package:africaonlinestores/features/sellers/domain/seller_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seller public identity', () {
    test('accepts canonical public seller IDs', () {
      expect(
        normalizePublicSellerId(' seller-abcdefghijklmnopqrst '),
        'SELLER-ABCDEFGHIJKLMNOPQRST',
      );
    });

    test('rejects email and account IDs', () {
      expect(normalizePublicSellerId('bobby@example.invalid'), isNull);
      expect(normalizePublicSellerId('ACC-ABCDEFGHIJKLMNOPQRST'), isNull);
    });

    test('selects the first canonical seller ID', () {
      expect(
        firstPublicSellerId(const <Object?>[
          'bobby@example.invalid',
          'SELLER-ABCDEFGHIJKLMNOPQRST',
        ]),
        'SELLER-ABCDEFGHIJKLMNOPQRST',
      );
    });
  });
}
