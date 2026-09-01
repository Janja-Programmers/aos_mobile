import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sellerLocationApiProvider = Provider<SellerLocationApi>((ref) {
  return SellerLocationApi(ref.read(apiClientProvider));
});

class SellerLocationSnapshot {
  const SellerLocationSnapshot({
    required this.location,
    required this.locationVersion,
  });

  final AOSPlace? location;
  final int locationVersion;
}

class SellerLocationApi {
  const SellerLocationApi(this._client);

  final ApiClient _client;

  Future<Either<Failure, SellerLocationSnapshot>> getSellerLocation({
    String? seller,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getSellerLocation,
        queryParameters: {
          if (seller?.trim().isNotEmpty ?? false) 'seller': seller!.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = asJsonMap(unwrapped.rightOrNull?['data']);
      final version = _int(data['location_version']) ?? 0;
      final rawLocation = data['location'];
      AOSPlace? location;
      if (rawLocation is Map) {
        final map = asJsonMap(rawLocation);
        final hasLocation =
            map['has_location'] == true ||
            map['has_location'] == 1 ||
            map['has_location']?.toString() == '1';
        if (hasLocation || map['latitude'] != null) {
          location = AOSPlace.fromJson({...map, 'location_version': version});
        }
      }

      return Either.right(
        SellerLocationSnapshot(location: location, locationVersion: version),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch seller location.'));
    }
  }

  Future<Either<Failure, AOSPlace>> setMySellerLocation({
    required double latitude,
    required double longitude,
    String? locationName,
    String? locationInstructions,
    int? expectedVersion,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.setMySellerLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'location_name': locationName?.trim() ?? '',
          'location_instructions': locationInstructions?.trim() ?? '',
          'expected_version': ?expectedVersion,
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = asJsonMap(unwrapped.rightOrNull?['data']);
      final location = data['location'];
      if (location is! Map) {
        return Either.left(
          const Failure(
            'Invalid seller location response.',
            type: FailureType.parse,
          ),
        );
      }

      return Either.right(
        AOSPlace.fromJson({
          ...asJsonMap(location),
          'location_version': data['location_version'],
        }),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to save seller location.'));
    }
  }

  Future<Either<Failure, int>> removeMySellerLocation({
    int? expectedVersion,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.removeMySellerLocation,
        data: {'expected_version': ?expectedVersion},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final data = asJsonMap(unwrapped.rightOrNull?['data']);
      return Either.right(
        _int(data['location_version']) ?? expectedVersion ?? 0,
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to remove seller location.'));
    }
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
