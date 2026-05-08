import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/toggle_like_result.dart';

class ShortsEngagementApi {
  final ApiClient _client;

  ShortsEngagementApi(this._client);

  // ───────────── TOGGLE LIKE ─────────────

  Future<Either<Failure, ToggleLikeResult>> toggleLike({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleShortLike,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json['message'] is Map<String, dynamic> &&
                  json['message']['data'] is Map<String, dynamic>
            ? json['message']['data'] as Map<String, dynamic>
            : json;

        final resultShortId = data['short_id'] as String? ?? shortId;
        final liked = data['liked'] as bool?;

        if (liked == null) {
          return Either.left(const Failure('Invalid toggle like response'));
        }

        return Either.right(
          ToggleLikeResult(shortId: resultShortId, liked: liked),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error toggling like'));
    }
  }
}
