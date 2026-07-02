import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/social/data/social_friends_page_model.dart';
import 'package:africaonlinestores/features/social/data/social_relationship_model.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';
import 'package:africaonlinestores/features/social/domain/social_relationship.dart';

class SocialApi {
  final ApiClient _apiClient;

  const SocialApi(this._apiClient);

  // -----------------------------
  // FOLLOWERS
  // -----------------------------
  Future<Either<Failure, SocialFriendsPage>> getFollowers({
    int limit = 20,
    int start = 0,
    String? targetUser,
    String? query,
  }) {
    return _getPeoplePage(
      endpoint: ApiEndpoints.getFollowsEndpoint,
      limit: limit,
      start: start,
      targetUser: targetUser,
      query: query,
      parseFailureMessage: 'Invalid followers response format',
      fallbackFailureMessage: 'Failed to load followers. Please try again.',
    );
  }

  // -----------------------------
  // FOLLOWING
  // -----------------------------
  Future<Either<Failure, SocialFriendsPage>> getFollowing({
    int limit = 20,
    int start = 0,
    String? targetUser,
    String? query,
  }) {
    return _getPeoplePage(
      endpoint: ApiEndpoints.getFollowingEndpoint,
      limit: limit,
      start: start,
      targetUser: targetUser,
      query: query,
      parseFailureMessage: 'Invalid following response format',
      fallbackFailureMessage: 'Failed to load following. Please try again.',
    );
  }

  // -----------------------------
  // FRIENDS
  // -----------------------------
  Future<Either<Failure, SocialFriendsPage>> getFriends({
    int limit = 20,
    int start = 0,
    String? targetUser,
    String? query,
  }) {
    return _getPeoplePage(
      endpoint: ApiEndpoints.getFriendsEndpoint,
      limit: limit,
      start: start,
      targetUser: targetUser,
      query: query,
      parseFailureMessage: 'Invalid friends response format',
      fallbackFailureMessage: 'Failed to load friends. Please try again.',
    );
  }

  // -----------------------------
  // TOGGLE FOLLOW
  // -----------------------------
  Future<Either<Failure, SocialRelationship>> toggleFollow({
    required String targetUser,
  }) async {
    try {
      final cleanTarget = targetUser.trim();

      if (cleanTarget.isEmpty) {
        return Either.left(
          const Failure(
            'Target user is required.',
            type: FailureType.validation,
          ),
        );
      }

      final res = await _apiClient.post(
        ApiEndpoints.toggleFollowEndpoint,
        data: {'target_user': cleanTarget},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final rawData = _extractData(result.rightOrNull);

      if (rawData is! Map) {
        return Either.left(
          const Failure(
            'Invalid follow response format',
            type: FailureType.parse,
          ),
        );
      }

      final relationship = SocialRelationshipModel.fromJson(
        Map<String, dynamic>.from(rawData),
      );

      return Either.right(relationship);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Failed to update follow status. Please try again.'),
      );
    }
  }

  // -----------------------------
  // RELATIONSHIP STATUS
  // -----------------------------
  Future<Either<Failure, SocialRelationship>> getRelationshipStatus({
    required String targetUser,
  }) async {
    try {
      final cleanTarget = targetUser.trim();

      if (cleanTarget.isEmpty) {
        return Either.left(
          const Failure(
            'Target user is required.',
            type: FailureType.validation,
          ),
        );
      }

      final res = await _apiClient.post(
        ApiEndpoints.getRelationshipStatusEndpoint,
        data: {'target_user': cleanTarget},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final rawData = _extractData(result.rightOrNull);

      if (rawData is! Map) {
        return Either.left(
          const Failure(
            'Invalid relationship response format',
            type: FailureType.parse,
          ),
        );
      }

      final relationship = SocialRelationshipModel.fromJson(
        Map<String, dynamic>.from(rawData),
      );

      return Either.right(relationship);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Failed to load relationship status. Please try again.'),
      );
    }
  }

  // -----------------------------
  // PRIVATE HELPERS
  // -----------------------------
  Future<Either<Failure, SocialFriendsPage>> _getPeoplePage({
    required String endpoint,
    required int limit,
    required int start,
    String? targetUser,
    String? query,
    required String parseFailureMessage,
    required String fallbackFailureMessage,
  }) async {
    try {
      final res = await _apiClient.get(
        endpoint,
        queryParameters: {
          'limit': limit,
          'start': start,
          if (targetUser?.trim().isNotEmpty == true) ...{
            'target_user': targetUser!.trim(),
            'user': targetUser.trim(),
          },
          if (query?.trim().isNotEmpty == true) ...{
            'q': query!.trim(),
            'search': query.trim(),
          },
        },
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final rawData = _extractData(result.rightOrNull);

      if (rawData is! Map) {
        return Either.left(
          Failure(parseFailureMessage, type: FailureType.parse),
        );
      }

      final page = SocialFriendsPageModel.fromJson(
        Map<String, dynamic>.from(rawData),
      );

      return Either.right(page);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(Failure(fallbackFailureMessage));
    }
  }

  dynamic _extractData(dynamic payload) {
    if (payload is Map && payload.containsKey('data')) {
      return payload['data'];
    }

    return null;
  }
}
