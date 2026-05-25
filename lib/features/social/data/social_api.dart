import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/social/data/social_friends_page_model.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';

class SocialApi {
  final ApiClient _apiClient;

  const SocialApi(this._apiClient);

  Future<Either<Failure, SocialFriendsPage>> getFriends({
    int limit = 20,
    int start = 0,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.getFriendsEndpoint,
        queryParameters: {'limit': limit, 'start': start},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final payload = result.rightOrNull;

      final rawData = payload?['data'];

      if (rawData is! Map) {
        return Either.left(
          const Failure(
            'Invalid friends response format',
            type: FailureType.parse,
          ),
        );
      }

      final page = SocialFriendsPageModel.fromJson(
        Map<String, dynamic>.from(rawData),
      );

      return Either.right(page);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Failed to load friends. Please try again.'),
      );
    }
  }
}
