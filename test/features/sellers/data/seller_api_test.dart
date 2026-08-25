import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/features/sellers/data/seller_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../../account_profile/helpers/account_profile_api_harness.dart';

void main() {
  group('SellerApi updateSeller', () {
    test('sends canonical seller banner media field only', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'message': 'Seller profile updated successfully.',
            'data': <String, dynamic>{
              'seller_id': 'SELLER-TEST-001',
              'shop_banner_media': 'MEDIA-SELLER-BANNER-001',
              'changed': true,
            },
          },
        }),
      );
      final harness = await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);
      final api = SellerApi(harness.client);

      final result = await api.updateSeller(
        shopBanner: ' MEDIA-SELLER-BANNER-001 ',
      );

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.method, 'POST');
      expect(adapter.singleRequest.path, ApiEndpoints.updateMySellerEndpoint);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'shop_banner_media': 'MEDIA-SELLER-BANNER-001',
      });
      expect(
        (adapter.singleRequest.data as Map<String, dynamic>).containsKey(
          'business_address',
        ),
        isFalse,
      );
    });

    test('clears banner with clear_shop_banner and no media field', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'message': 'Seller profile updated successfully.',
            'data': <String, dynamic>{
              'seller_id': 'SELLER-TEST-001',
              'shop_banner_media': null,
              'changed': true,
            },
          },
        }),
      );
      final harness = await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);
      final api = SellerApi(harness.client);

      final result = await api.updateSeller(clearShopBanner: true);

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'clear_shop_banner': true,
      });
    });
  });
}
