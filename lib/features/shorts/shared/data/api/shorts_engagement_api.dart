import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/toggle_follow_result.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/toggle_like_result.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/toggle_save_result.dart';
import 'package:dio/dio.dart';

class ShortsEngagementApi {
  final ApiClient _client;

  ShortsEngagementApi(this._client);

  Future<Either<Failure, ToggleLikeResult>> toggleLike({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleShortLike,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);
        final resultShortId = data['short_id']?.toString() ?? shortId;
        final viewerState = asJsonMap(data['viewer_state']);
        final likedRaw = data['liked'] ?? viewerState['is_liked'];

        if (likedRaw == null) {
          return Either.left(const Failure('Invalid toggle like response'));
        }

        return Either.right(
          ToggleLikeResult(shortId: resultShortId, liked: _toBool(likedRaw)),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error toggling like'));
    }
  }

  Future<Either<Failure, ToggleFollowResult>> toggleFollow({
    required String targetUser,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleFollowEndpoint,
        data: {'target_user': targetUser},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);

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

  Future<Either<Failure, ToggleSaveResult>> toggleSave({
    required String shortId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleShortSave,
        data: {'short_id': shortId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);
        final resultShortId = data['short_id']?.toString() ?? shortId;
        final viewerState = asJsonMap(data['viewer_state']);
        final savedRaw = data['saved'] ?? viewerState['is_saved'];

        if (savedRaw == null) {
          return Either.left(const Failure('Invalid toggle save response'));
        }

        final metrics = data['metrics'];
        final saveCount = metrics is Map<String, dynamic>
            ? _toNullableInt(metrics['save_count'])
            : _toNullableInt(data['save_count']);

        return Either.right(
          ToggleSaveResult(
            shortId: resultShortId,
            saved: _toBool(savedRaw),
            saveCount: saveCount,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error toggling save'));
    }
  }

  static Map<String, dynamic> _payload(Map<String, dynamic> json) {
    final data = asJsonMap(json['data']);
    if (data.isNotEmpty) return data;

    final message = asJsonMap(json['message']);
    final nestedData = asJsonMap(message['data']);
    if (nestedData.isNotEmpty) return nestedData;

    return json;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value?.toString().trim().toLowerCase();

    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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
