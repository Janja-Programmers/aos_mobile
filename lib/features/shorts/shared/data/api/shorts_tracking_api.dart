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

  Future<Either<Failure, void>> trackImpression({
    required String shortId,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.trackShortImpression,
        data: {
          'short_id': shortId,
          if (sessionId != null && sessionId.trim().isNotEmpty)
            'session_id': sessionId.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error tracking impression'));
    }
  }

  Future<Either<Failure, void>> trackView({
    required String shortId,
    required int watchMs,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.trackShortView,
        data: {
          'short_id': shortId,
          'watch_ms': watchMs.clamp(0, 1 << 31),
          if (sessionId != null && sessionId.trim().isNotEmpty)
            'session_id': sessionId.trim(),
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error tracking view'));
    }
  }
}
