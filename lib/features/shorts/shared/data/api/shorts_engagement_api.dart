import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/toggle_like_result.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/toggle_follow_result.dart';

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

  // ───────────── TOGGLE FOLLOW ─────────────

  Future<Either<Failure, ToggleFollowResult>> toggleFollow({
    required String targetUser,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleFollowEndpoint,
        data: {'target_user': targetUser},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json['message'] is Map<String, dynamic> &&
                  json['message']['data'] is Map<String, dynamic>
            ? json['message']['data'] as Map<String, dynamic>
            : json;

        final resultTargetUser =
            data['target_user']?.toString() ??
            data['following_user']?.toString() ??
            targetUser;

        final isFollowing = _toBool(data['is_following']);
        final isFollowedBy = _toBool(data['is_followed_by']);
        final isFriend = _toBool(data['is_friend']);

        final relationshipStatus =
            data['relationship_status']?.toString() ??
            _relationshipStatusFor(
              isFollowing: isFollowing,
              isFollowedBy: isFollowedBy,
            );

        final actionLabel =
            data['action_label']?.toString() ??
            (isFollowing ? 'Following' : 'Follow');

        return Either.right(
          ToggleFollowResult(
            targetUser: resultTargetUser,
            isFollowing: isFollowing,
            isFollowedBy: isFollowedBy,
            isFriend: isFriend,
            relationshipStatus: relationshipStatus,
            actionLabel: actionLabel,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error toggling follow'));
    }
  }

  // ───────────── TOGGLE SAVE ─────────────

  Future<Either<Failure, ToggleLikeResult>> toggleSave({
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

  // ───────────── HELPERS  ─────────────

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value?.toString().trim().toLowerCase();

    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static String _relationshipStatusFor({
    required bool isFollowing,
    required bool isFollowedBy,
  }) {
    if (isFollowing && isFollowedBy) return 'friends';
    if (isFollowing) return 'following';
    if (isFollowedBy) return 'followed_by';

    return 'none';
  }
}
