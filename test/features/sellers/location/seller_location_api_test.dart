import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/features/sellers/location/data/seller_location_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../../account_profile/helpers/account_profile_api_harness.dart';

void main() {
  test(
    'seller location preserves location_version and sends expected_version',
    () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        if (options.method == 'GET') {
          return jsonResponse(<String, dynamic>{
            'message': <String, dynamic>{
              'ok': true,
              'data': <String, dynamic>{
                'location_version': 7,
                'location': <String, dynamic>{
                  'has_location': true,
                  'name': 'Posta',
                  'display_address': 'Mombasa, Kenya',
                  'latitude': -4.0435,
                  'longitude': 39.6682,
                },
              },
            },
          });
        }
        return jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{
              'location_version': 8,
              'location': <String, dynamic>{
                'has_location': true,
                'name': 'Posta',
                'display_address': 'Mombasa, Kenya',
                'latitude': -4.0435,
                'longitude': 39.6682,
              },
            },
          },
        });
      });
      final harness = await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);
      final api = SellerLocationApi(harness.client);

      final loaded = await api.getSellerLocation();
      expect(loaded.isRight, isTrue);
      expect(loaded.rightOrNull?.locationVersion, 7);

      final saved = await api.setMySellerLocation(
        latitude: -4.0435,
        longitude: 39.6682,
        locationName: 'Posta',
        expectedVersion: 7,
      );
      expect(saved.isRight, isTrue);
      expect(saved.rightOrNull?.locationVersion, 8);

      final request = adapter.requests.last;
      expect(request.path, ApiEndpoints.setMySellerLocation);
      expect((request.data as Map<String, dynamic>)['expected_version'], 7);
    },
  );

  test('remove location sends expected_version when known', () async {
    final adapter = RecordingHttpClientAdapter(
      (_) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{'ok': true, 'data': <String, dynamic>{}},
      }),
    );
    final harness = await buildAccountProfileApiHarness(adapter);
    addTearDown(harness.container.dispose);
    final api = SellerLocationApi(harness.client);

    final result = await api.removeMySellerLocation(expectedVersion: 4);
    expect(result.isRight, isTrue);
    expect(adapter.singleRequest.path, ApiEndpoints.removeMySellerLocation);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'expected_version': 4,
    });
  });
}
