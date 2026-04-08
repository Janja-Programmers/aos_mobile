import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class ShortsTrackingApi {
  final ApiClient _client;

  ShortsTrackingApi(this._client);

  // ───────────── TRACK IMPRESSION ─────────────
  // Called when short becomes visible

  Future<Either<Failure, Map<String, dynamic>>> trackImpression({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.trackShortImpression,
        data: {'short_id': shortId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error tracking impression'));
    }
  }

  // ───────────── TRACK VIEW ─────────────
  // Called when playback threshold reached

  Future<Either<Failure, Map<String, dynamic>>> trackView({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.trackShortView,
        data: {'short_id': shortId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error tracking view'));
    }
  }
}
