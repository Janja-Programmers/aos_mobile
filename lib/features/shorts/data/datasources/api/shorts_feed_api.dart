import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class ShortsFeedApi {
  final ApiClient _client;

  ShortsFeedApi(this._client);

  // ───────────── FOR YOU ─────────────

  Future<Either<Failure, Map<String, dynamic>>> fetchForYou({
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.shortsFeedForYou,
        queryParameters: {'cursor': ?cursor},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching feed'));
    }
  }

  // ───────────── FOLLOWING ─────────────

  Future<Either<Failure, Map<String, dynamic>>> fetchFollowing({
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.shortsFeedFollowing,
        queryParameters: {'cursor': ?cursor},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error fetching following feed'),
      );
    }
  }

  // ───────────── BY AD ─────────────

  Future<Either<Failure, Map<String, dynamic>>> fetchByAd({
    required String adId,
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.shortsFeedByAd,
        queryParameters: {'ad_id': adId, 'cursor': ?cursor},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching ad feed'));
    }
  }
}
