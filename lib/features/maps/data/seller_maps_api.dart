import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/maps/domain/seller_location_response.dart';
import 'package:africaonlinestores/features/maps/domain/seller_map_point.dart';
import 'package:africaonlinestores/features/maps/domain/seller_nearby_item.dart';

final sellerMapsApiProvider = Provider<SellerMapsApi>((ref) {
  return SellerMapsApi(ref.read(apiClientProvider));
});

class SellerMapsApi {
  const SellerMapsApi(this._client);

  final ApiClient _client;

  Future<Either<Failure, SellerLocationResponse>> getSellerLocation({
    String? seller,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getSellerLocation,
        queryParameters: {
          if (seller != null && seller.trim().isNotEmpty)
            'seller': seller.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = _dataMap(unwrapped.rightOrNull);
      return Either.right(SellerLocationResponse.fromJson(data));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch seller location.'));
    }
  }

  Future<Either<Failure, List<SellerNearbyItem>>> listNearbySellers({
    required double latitude,
    required double longitude,
    double radiusKm = 20,
    int limit = 20,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listSellersEndpoint,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm,
          'sort': 'nearest',
          'limit': limit,
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = _dataMap(unwrapped.rightOrNull);
      final rawItems = data['items'] ?? data['sellers'] ?? const [];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (e) =>
                      SellerNearbyItem.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList(growable: false)
          : <SellerNearbyItem>[];
      return Either.right(items);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch nearby sellers.'));
    }
  }

  Future<Either<Failure, List<SellerMapPoint>>> listSellerMapPoints({
    required double south,
    required double north,
    required double west,
    required double east,
    required int zoom,
    int limit = 100,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listSellerMapPoints,
        queryParameters: {
          'south': south,
          'north': north,
          'west': west,
          'east': east,
          'zoom': zoom,
          'limit': limit,
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = _dataMap(unwrapped.rightOrNull);
      final rawItems = data['items'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (e) => SellerMapPoint.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList(growable: false)
          : <SellerMapPoint>[];
      return Either.right(items);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch sellers on map.'));
    }
  }

  static Map<String, dynamic> _dataMap(Map<String, dynamic>? payload) {
    final data = payload?['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return payload == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(payload);
  }
}
