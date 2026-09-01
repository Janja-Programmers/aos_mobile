import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/features/maps/data/seller_maps_api.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/recording_http_client_adapter.dart';
import '../account_profile/helpers/account_profile_api_harness.dart';

void main() {
  test(
    'seller map points uses only backend-supported viewport parameters',
    () async {
      final adapter = RecordingHttpClientAdapter(
        (_) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{'items': <Object>[]},
          },
        }),
      );
      final harness = await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);
      final api = SellerMapsApi(harness.client);

      final result = await api.listSellerMapPoints(
        south: -4.1,
        north: -4.0,
        west: 39.6,
        east: 39.7,
        zoom: 14,
      );

      expect(result.isRight, isTrue);
      final request = adapter.singleRequest;
      expect(request.path, ApiEndpoints.listSellerMapPoints);
      expect(request.queryParameters.containsKey('limit'), isFalse);
      expect(request.queryParameters['zoom'], 14);
    },
  );
}
