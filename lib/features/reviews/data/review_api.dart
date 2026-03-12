import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';

/// Provider for Review API
final reviewApiProvider = Provider<ReviewApi>((ref) {
  return ReviewApi(ref.read(apiClientProvider));
});

class ReviewApi {
  final ApiClient _client;

  ReviewApi(this._client);

  /// GET REVIEWS FOR AN AD
  Future<Either<Failure, Map<String, dynamic>>> getAdReviews({
    required String adId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getAdReviewsEndpoint,
        queryParameters: {'ad': adId, 'limit': limit, 'offset': offset},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch reviews.'));
    }
  }

  /// CREATE REVIEW
  Future<Either<Failure, void>> createAdReview({
    required String ad,
    required double rating,
    required String title,
    required String comment,
    List<String>? images,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.createAdReviewEndpoint,
        data: {
          "ad": ad,
          "rating": rating,
          "title": title,
          "comment": comment,
          "images": images ?? [],
        },
      );

      final parsed = unwrapFrappe(res);

      return parsed.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to create review.'));
    }
  }
}
