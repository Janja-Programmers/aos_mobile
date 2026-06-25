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

final sellerLocationApiProvider = Provider<SellerLocationApi>((ref) {
  return SellerLocationApi(ref.read(apiClientProvider));
});

class SellerLocationApi {
  final ApiClient _client;

  const SellerLocationApi(this._client);

  Future<Either<Failure, AOSPlace?>> getSellerLocation({String? seller}) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getSellerLocation,
        queryParameters: {
          if (seller?.trim().isNotEmpty == true) 'seller': seller!.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = unwrapped.rightOrNull?['data'];
      final location = data is Map ? data['location'] : null;
      if (location is! Map) return Either.right(null);

      final map = Map<String, dynamic>.from(location);
      final hasLocation =
          map['has_location'] == true ||
          map['has_location'] == 1 ||
          map['has_location']?.toString() == '1';
      if (!hasLocation && map['latitude'] == null) return Either.right(null);

      return Either.right(AOSPlace.fromJson(map));
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
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.setMySellerLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'location_name': locationName?.trim() ?? '',
          'location_instructions': locationInstructions?.trim() ?? '',
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);

      final data = unwrapped.rightOrNull?['data'];
      final location = data is Map ? data['location'] : null;
      if (location is! Map) {
        return Either.left(
          const Failure(
            'Invalid seller location response.',
            type: FailureType.parse,
          ),
        );
      }

      return Either.right(
        AOSPlace.fromJson(Map<String, dynamic>.from(location)),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to save seller location.'));
    }
  }

  Future<Either<Failure, void>> removeMySellerLocation() async {
    try {
      final res = await _client.post(ApiEndpoints.removeMySellerLocation);
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to remove seller location.'));
    }
  }
}
