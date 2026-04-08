import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class ShortsEngagementApi {
  final ApiClient _client;

  ShortsEngagementApi(this._client);

  // ───────────── TOGGLE LIKE ─────────────

  Future<Either<Failure, Map<String, dynamic>>> toggleLike({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleShortLike,
        data: {'short_id': shortId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error toggling like'));
    }
  }
}
