import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/maps/domain/aos_route.dart';

final mapsApiProvider = Provider<MapsApi>((ref) {
  return MapsApi(ref.read(apiClientProvider));
});

class MapsApi {
  final ApiClient _client;

  const MapsApi(this._client);

  Future<Either<Failure, List<AOSPlace>>> searchPlaces({
    required String query,
    int limit = 10,
    bool bounded = true,
  }) async {
    try {
      final clean = query.trim();
      if (clean.length < 2) return Either.right(const []);

      final res = await _client.get(
        ApiEndpoints.searchPlaces,
        queryParameters: {
          'query': clean,
          'limit': limit,
          'bounded': bounded ? 1 : 0,
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = unwrapped.rightOrNull?['data'];
      final rawItems = data is Map ? data['items'] : null;
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((e) => AOSPlace.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : <AOSPlace>[];
      return Either.right(items);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to search places.'));
    }
  }

  Future<Either<Failure, AOSPlace>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.reverseGeocode,
        queryParameters: {'latitude': latitude, 'longitude': longitude},
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = unwrapped.rightOrNull?['data'];
      final rawLocation = data is Map ? data['location'] : null;
      if (rawLocation is! Map) {
        return Either.left(
          const Failure(
            'Invalid reverse-geocode response.',
            type: FailureType.parse,
          ),
        );
      }

      return Either.right(
        AOSPlace.fromJson(Map<String, dynamic>.from(rawLocation)),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to resolve location.'));
    }
  }

  Future<Either<Failure, AOSRoute>> getRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    String costing = 'auto',
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.getRoute,
        data: {
          'origin_latitude': originLatitude,
          'origin_longitude': originLongitude,
          'destination_latitude': destinationLatitude,
          'destination_longitude': destinationLongitude,
          'costing': costing,
          'units': 'kilometers',
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = unwrapped.rightOrNull?['data'];
      final rawRoute = data is Map ? data['route'] : null;
      if (rawRoute is! Map) {
        return Either.left(
          const Failure('Invalid route response.', type: FailureType.parse),
        );
      }

      return Either.right(
        AOSRoute.fromJson(Map<String, dynamic>.from(rawRoute)),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to calculate route.'));
    }
  }
}
