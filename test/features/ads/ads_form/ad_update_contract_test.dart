import 'package:africaonlinestores/features/ads/ads_form/utils/ad_update_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdUpdateContract', () {
    test('Active only sends backend safe-edit fields', () {
      final result = AdUpdateContract.payloadForStatus(
        status: 'Active',
        candidate: <String, dynamic>{
          'title': 'Updated title',
          'description': 'Updated description long enough',
          'category': 'CAT-NEW',
          'location': 'LOC-NEW',
          'images': const <Object>[],
          'price_type': 'Fixed',
          'price': 100,
        },
      );

      expect(result.isRight, isTrue);
      expect(result.rightOrNull, <String, dynamic>{
        'title': 'Updated title',
        'description': 'Updated description long enough',
        'price_type': 'Fixed',
        'price': 100,
      });
    });

    test('Reviewing and Declined allow backend full-edit fields', () {
      for (final status in <String>['Reviewing', 'Declined']) {
        final result = AdUpdateContract.payloadForStatus(
          status: status,
          candidate: <String, dynamic>{
            'title': 'Updated title',
            'category': 'CAT-1',
            'location': 'LOC-1',
            'details': const <Object>[],
            'images': const <Object>[],
            'unknown': true,
          },
        );

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.containsKey('unknown'), isFalse);
        expect(result.rightOrNull, containsPair('category', 'CAT-1'));
        expect(result.rightOrNull, containsPair('location', 'LOC-1'));
      }
    });

    test('backend blocked edit statuses fail before request', () {
      for (final status in <String>[
        'Sold',
        'Expired',
        'Deleted',
        'Suspended',
      ]) {
        final result = AdUpdateContract.payloadForStatus(
          status: status,
          candidate: <String, dynamic>{'title': 'Updated title'},
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull?.error, 'INVALID_AD_STATE');
        expect(result.leftOrNull?.message, isNotEmpty);
      }
    });
  });
}
