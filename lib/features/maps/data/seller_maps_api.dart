import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/maps/domain/seller_location_response.dart';
import 'package:africaonlinestores/features/maps/domain/seller_map_point.dart';
import 'package:africaonlinestores/features/maps/domain/seller_nearby_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final rawItems = data['items'] ?? data['sellers'];
      final items = asJsonMapList(
        rawItems,
      ).map(SellerNearbyItem.fromJson).toList(growable: false);
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
      final items = asJsonMapList(
        data['items'],
      ).map(SellerMapPoint.fromJson).toList(growable: false);
      return Either.right(items);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch sellers on map.'));
    }
  }

  static Map<String, dynamic> _dataMap(Map<String, dynamic>? payload) {
    if (payload == null) return <String, dynamic>{};

    final data = asJsonMap(payload['data']);
    if (data.isNotEmpty) return data;

    return asJsonMap(payload);
  }
}
