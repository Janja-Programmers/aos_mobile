import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/reviews/application/state/review_viewer_state.dart';
import 'package:africaonlinestores/features/reviews/domain/review_sort.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewApiProvider = Provider<ReviewApi>((ref) {
  return ReviewApi(ref.read(apiClientProvider));
});

class ReviewApi {
  ReviewApi(this._client);

  static const _reportReviewEndpoint =
      '/api/method/aos.api.v1.reviews.report_review';

  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getAdReviews({
    required String adId,
    ReviewSort sort = ReviewSort.newest,
    int? rating,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'ad': adId,
        'sort': sort.apiValue,
        'limit': limit,
        'offset': offset,
      };

      if (rating != null) {
        queryParameters['rating'] = rating;
      }

      final res = await _client.get(
        ApiEndpoints.getAdReviewsEndpoint,
        queryParameters: queryParameters,
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch reviews.'));
    }
  }

  Future<Either<Failure, void>> createAdReview({
    required String ad,
    required double rating,
    required String title,
    required String comment,
    List<String>? images,
  }) async {
    if ((images?.length ?? 0) > 5) {
      return Either.left(const Failure('Maximum 5 images allowed.'));
    }

    try {
      final res = await _client.post(
        ApiEndpoints.createAdReviewEndpoint,
        data: {
          'ad': ad,
          'rating': rating,
          'title': title,
          'comment': comment,
          'images': images ?? [],
        },
      );

      final parsed = unwrapFrappe(res);

      return parsed.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to create review.'));
    }
  }

  Future<Either<Failure, void>> toggleReview({
    required String reviewId,
    required String reaction,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleAdReviewEndpoint,
        data: {'review': reviewId, 'reaction': reaction},
      );

      final parsed = unwrapFrappe(res);

      return parsed.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to toggle review.'));
    }
  }

  Future<Either<Failure, void>> reportReview({
    required String reviewId,
    required String reason,
    required String details,
  }) async {
    try {
      final res = await _client.post(
        _reportReviewEndpoint,
        data: {
          'review': reviewId,
          'reason': reason,
          'details': details,
        },
      );

      final parsed = unwrapFrappe(res);
      return parsed.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to report review.'));
    }
  }

  Future<Either<Failure, ReviewViewerState>> getReviewViewerState({
    required String ad,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.getReviewViewerState,
        queryParameters: {'ad': ad},
      );

      final parsed = unwrapFrappe(res);

      return parsed.fold(Either.left, (payload) {
        final data = payload['data'];

        if (data is! Map) {
          return Either.left(
            const Failure('Invalid review viewer state response.'),
          );
        }

        return Either.right(ReviewViewerState.fromJson(asJsonMap(data)));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch review viewer state.'));
    }
  }
}
