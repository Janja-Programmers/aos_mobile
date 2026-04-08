import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class ShortsCommentsApi {
  final ApiClient _client;

  ShortsCommentsApi(this._client);

  // ───────────── LIST COMMENTS (TOP LEVEL) ─────────────

  Future<Either<Failure, Map<String, dynamic>>> listComments({
    required String shortId,
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listShortComments,
        queryParameters: {
          'short_id': shortId,
          'cursor': ?cursor,
        },
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching comments'));
    }
  }

  // ───────────── LIST REPLIES ─────────────

  Future<Either<Failure, Map<String, dynamic>>> listReplies({
    required String commentId,
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listShortReplies,
        queryParameters: {
          'comment_id': commentId,
          'cursor': ?cursor,
        },
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error fetching replies'));
    }
  }

  // ───────────── ADD COMMENT ─────────────

  Future<Either<Failure, Map<String, dynamic>>> addComment({
    required String shortId,
    required String content,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.addShortComment,
        data: {'short_id': shortId, 'content': content},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error adding comment'));
    }
  }

  // ───────────── REPLY COMMENT ─────────────

  Future<Either<Failure, Map<String, dynamic>>> replyComment({
    required String parentCommentId,
    required String content,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.replyShortComment,
        data: {'parent_comment_id': parentCommentId, 'content': content},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error replying to comment'));
    }
  }

  // ───────────── DELETE COMMENT ─────────────

  Future<Either<Failure, Map<String, dynamic>>> deleteComment({
    required String commentId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteShortComment,
        data: {'comment_id': commentId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error deleting comment'));
    }
  }
}
