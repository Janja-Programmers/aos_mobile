import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/short_metrics.dart';

class ShortsEngagementApi {
  final ApiClient _client;

  ShortsEngagementApi(this._client);

  // ───────────── TOGGLE LIKE ─────────────

  Future<Either<Failure, ShortMetrics>> toggleLike({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleShortLike,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        return Either.right(
          ShortMetrics(
            likeCount: json['like_count'] ?? 0,
            commentCount: json['comment_count'] ?? 0,
            viewCount: json['view_count'] ?? 0,
            likedByMe: json['liked_by_me'] ?? true,
            shareCount: json['share_count'] ?? 0,
            impressionCount: json['impression_count'] ?? 0,
            rankingScore: json['ranking_score'] ?? 0,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error toggling like'));
    }
  }
}
