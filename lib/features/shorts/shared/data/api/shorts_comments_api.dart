import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_comment_model.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/comment_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/short_comment.dart';

class ShortsCommentsApi {
  final ApiClient _client;

  ShortsCommentsApi(this._client);

  // ───────────── LIST COMMENTS (TOP LEVEL) ─────────────

  Future<Either<Failure, List<ShortComment>>> listComments({
    required String shortId,
    String? cursor,
  }) async {
    try {
      final query = {'short_id': shortId, 'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.listShortComments,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};

        final items = (data['items'] as List? ?? [])
            .map((e) => CommentMapper.toDomain(ShortCommentModel.fromJson(e)))
            .toList();

        return Either.right(items);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching comments'));
    }
  }

  // ───────────── LIST REPLIES ─────────────

  Future<Either<Failure, List<ShortComment>>> listReplies({
    required String rootCommentId,
    String? cursor,
  }) async {
    try {
      final query = {'root_comment_id': rootCommentId, 'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.listShortReplies,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};

        final items = (data['items'] as List? ?? [])
            .map((e) => CommentMapper.toDomain(ShortCommentModel.fromJson(e)))
            .toList();

        return Either.right(items);
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

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>?;

        if (data == null) {
          return Either.left(const Failure('Invalid comment response'));
        }

        // ⚠️ backend only returns comment_id
        final commentId = data['comment_id'] as String?;

        if (commentId == null) {
          return Either.left(const Failure('Missing comment_id'));
        }

        // 🔥 create minimal model manually
        final model = ShortCommentModel(
          id: commentId,
          shortId: shortId,
          userId: '', // optional for now
          comment: comment,
          parentId: null,
          rootId: null,
          replyCount: 0,
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

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};

        final commentId = data['comment_id'] as String?;

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

      return unwrapped.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(null),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error deleting comment'));
    }
  }
}
