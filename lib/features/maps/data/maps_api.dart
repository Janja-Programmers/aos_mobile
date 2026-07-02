import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/maps/domain/aos_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

      final data = _dataMap(unwrapped.rightOrNull);
      final rawItems = data['items'] ?? data['places'] ?? data['results'];
      return Either.right(_placeList(rawItems));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to search places.'));
    }
  }

  Future<Either<Failure, List<AOSPlace>>> autocompletePlaces({
    required String query,
    int limit = 5,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final clean = query.trim();
      if (clean.length < 2) return Either.right(const []);

      final res = await _client.get(
        ApiEndpoints.autocompletePlaces,
        queryParameters: {
          'query': clean,
          'limit': limit,
          'latitude': ?latitude,
          'longitude': ?longitude,
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = _dataMap(unwrapped.rightOrNull);
      return Either.right(_placeList(data['items'] ?? data['places']));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to autocomplete places.'));
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

      final data = _dataMap(unwrapped.rightOrNull);
      final rawLocation = data['location'] ?? data['item'];
      if (rawLocation is! Map && data.isEmpty) {
        return Either.left(
          const Failure(
            'Invalid reverse-geocode response.',
            type: FailureType.parse,
          ),
        );
      }

      final map = rawLocation is Map ? asJsonMap(rawLocation) : asJsonMap(data);

      return Either.right(AOSPlace.fromJson(map));
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
    return _routeRequest(
      endpoint: ApiEndpoints.getRoute,
      data: {
        'origin_latitude': originLatitude,
        'origin_longitude': originLongitude,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'costing': costing,
        'units': 'kilometers',
      },
      fallbackMessage: 'Failed to calculate route.',
    );
  }

  Future<Either<Failure, AOSRoute>> getRouteToSeller({
    required double originLatitude,
    required double originLongitude,
    required String destinationSeller,
    String costing = 'auto',
    String units = 'kilometers',
  }) async {
    return _routeRequest(
      endpoint: ApiEndpoints.getRoute,
      data: {
        'origin_latitude': originLatitude,
        'origin_longitude': originLongitude,
        'destination_seller': destinationSeller,
        'costing': costing,
        'units': units,
      },
      fallbackMessage: 'Failed to calculate route to seller.',
    );
  }

  Future<Either<Failure, AOSRoute>> refreshRouteToSeller({
    required double currentLatitude,
    required double currentLongitude,
    required String destinationSeller,
    String costing = 'auto',
    String units = 'kilometers',
  }) async {
    return _routeRequest(
      endpoint: ApiEndpoints.refreshRoute,
      data: {
        'current_latitude': currentLatitude,
        'current_longitude': currentLongitude,
        'destination_seller': destinationSeller,
        'costing': costing,
        'units': units,
      },
      fallbackMessage: 'Failed to refresh route.',
    );
  }

  Future<Either<Failure, AOSRoute>> _routeRequest({
    required String endpoint,
    required Map<String, dynamic> data,
    required String fallbackMessage,
  }) async {
    try {
      final res = await _client.post(endpoint, data: data);
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final payload = unwrapped.rightOrNull ?? const <String, dynamic>{};
      final dataMap = _dataMap(payload);
      final rawRoute = dataMap['route'] ?? payload['route'];
      if (rawRoute is! Map) {
        return Either.left(
          const Failure('Invalid route response.', type: FailureType.parse),
        );
      }

      return Either.right(AOSRoute.fromJson(asJsonMap(rawRoute)));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(Failure(fallbackMessage));
    }
  }

  static Map<String, dynamic> _dataMap(Map<String, dynamic>? payload) {
    if (payload == null) return <String, dynamic>{};

    final data = asJsonMap(payload['data']);
    if (data.isNotEmpty) return data;

    return asJsonMap(payload);
  }

  static List<AOSPlace> _placeList(Object? value) {
    return asJsonMapList(value).map(AOSPlace.fromJson).toList(growable: false);
  }
}
