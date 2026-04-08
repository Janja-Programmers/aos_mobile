import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';

class ShortsManagementApi {
  final ApiClient _client;

  ShortsManagementApi(this._client);

  // ───────────── GET SINGLE SHORT ─────────────

  Future<Either<Failure, Map<String, dynamic>>> getShort({
    required String shortId,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getShort,
        queryParameters: {'short_id': shortId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching short'));
    }
  }

  // ───────────── MY SHORTS ─────────────

  Future<Either<Failure, Map<String, dynamic>>> myShorts({
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.myShorts,
        queryParameters: {'cursor': ?cursor},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching my shorts'));
    }
  }

  // ───────────── DELETE SHORT ─────────────

  Future<Either<Failure, Map<String, dynamic>>> deleteShort({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteShort,
        data: {'short_id': shortId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error deleting short'));
    }
  }

  // ───────────── RETRY PROCESSING ─────────────

  Future<Either<Failure, Map<String, dynamic>>> retryProcessing({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.retryProcessing,
        data: {'short_id': shortId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error retrying processing'));
    }
  }
}
