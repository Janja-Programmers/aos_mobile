import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/comment_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_comment_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_comments_page.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/togggle_comment_like_result.dart';
import 'package:dio/dio.dart';

class ShortsCommentsApi {
  final ApiClient _client;

  ShortsCommentsApi(this._client);

  // ───────────── LIST COMMENTS (TOP LEVEL) ─────────────

  Future<Either<Failure, ShortCommentsPage>> listComments({
    required String shortId,
    String? cursor,
  }) async {
    try {
      final query = <String, dynamic>{
        'short_id': shortId,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };

      final res = await _client.get(
        ApiEndpoints.listShortComments,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(
        (failure) {
          return Either.left(failure);
        },
        (json) {
          final data = asJsonMap(json['data']);

          final items = asJsonMapList(data['items']).map((e) {
            try {
              return CommentMapper.toDomain(ShortCommentModel.fromJson(e));
            } catch (_) {
              rethrow;
            }
          }).toList();

          return Either.right(
            ShortCommentsPage(
              items: items,
              nextCursor: data['next_cursor']?.toString(),
              hasMore: _toBool(data['has_more']),
            ),
          );
        },
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(const Failure('Unexpected error fetching comments'));
    }
  }

  // ───────────── LIST REPLIES ─────────────

  Future<Either<Failure, ShortCommentsPage>> listReplies({
    required String rootCommentId,
    String? cursor,
  }) async {
    try {
      final query = <String, dynamic>{
        'root_comment_id': rootCommentId,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };

      final res = await _client.get(
        ApiEndpoints.listShortReplies,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);

        final items = asJsonMapList(data['items'])
            .map((e) => CommentMapper.toDomain(ShortCommentModel.fromJson(e)))
            .toList();

        return Either.right(
          ShortCommentsPage(
            items: items,
            nextCursor: data['next_cursor']?.toString(),
            hasMore: _toBool(data['has_more']),
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching replies'));
    }
  }

  // ───────────── ADD COMMENT ─────────────

  Future<Either<Failure, ShortComment>> addComment({
    required String shortId,
    required String comment,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.addShortComment,
        data: {'short_id': shortId, 'comment': comment},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);

        if (data.isEmpty) {
          return Either.left(const Failure('Invalid comment response'));
        }

        // ⚠️ backend only returns comment_id
        final commentId = asNullableString(data['comment_id']);

        if (commentId == null) {
          return Either.left(const Failure('Missing comment_id'));
        }

        // 🔥 create minimal model manually
        final model = ShortCommentModel(
          id: commentId,
          shortId: shortId,
          userId: '',
          displayName: 'You',
          comment: comment,
          replyCount: 0,
          likeCount: 0,
          isLiked: false,
          isOwner: true,
          canDelete: true,
          isDeleted: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        return Either.right(CommentMapper.toDomain(model));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error adding comment'));
    }
  }

  // ───────────── REPLY COMMENT ─────────────

  Future<Either<Failure, String>> replyComment({
    required String parentCommentId,
    required String comment,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.replyShortComment,
        data: {'parent_comment_id': parentCommentId, 'comment': comment},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);

        final commentId = asNullableString(data['comment_id']);

        if (commentId == null) {
          return Either.left(
            const Failure('Invalid reply response', type: FailureType.parse),
          );
        }

        return Either.right(commentId);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error replying to comment'));
    }
  }

  // ───────────── LIKE COMMENT ─────────────

  Future<Either<Failure, ToggleCommentLikeResult>> toggleCommentLike({
    required String commentId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleShortCommentLike,
        data: {'comment_id': commentId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = _payload(json);

        final resultCommentId =
            data['comment_id']?.toString() ??
            data['id']?.toString() ??
            commentId;

        final likedRaw = data['liked'] ?? data['is_liked'];

        if (likedRaw == null) {
          return Either.left(
            const Failure('Invalid toggle comment like response'),
          );
        }

        return Either.right(
          ToggleCommentLikeResult(
            commentId: resultCommentId,
            liked: _toBool(likedRaw),
            likeCount: data.containsKey('like_count')
                ? _toInt(data['like_count'])
                : null,
          ),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error toggling comment like'),
      );
    }
  }

  // ───────────── DELETE COMMENT ─────────────

  Future<Either<Failure, void>> deleteComment({
    required String commentId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteShortComment,
        data: {'comment_id': commentId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error deleting comment'));
    }
  }

  // ───────────── HELPERS ─────────────

  static Map<String, dynamic> _payload(Map<String, dynamic> json) {
    final data = asJsonMap(json['data']);
    if (data.isNotEmpty) return data;

    final message = asJsonMap(json['message']);
    final nestedData = asJsonMap(message['data']);
    if (nestedData.isNotEmpty) return nestedData;

    return json;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value?.toString().trim().toLowerCase();

    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
