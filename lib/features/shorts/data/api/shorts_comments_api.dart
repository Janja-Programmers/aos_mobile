import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/shorts/data/models/short_comment_model.dart';
import 'package:africaonlinestores/features/shorts/data/mappers/comment_mapper.dart';
import 'package:africaonlinestores/features/shorts/domain/short_comment.dart';

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
        final items = (json['items'] as List? ?? [])
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
    required String commentId,
    String? cursor,
  }) async {
    try {
      final query = {'comment_id': commentId, 'cursor': ?cursor};

      final res = await _client.get(
        ApiEndpoints.listShortReplies,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final items = (json['items'] as List? ?? [])
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
    required String content,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.addShortComment,
        data: {'short_id': shortId, 'content': content},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final model = ShortCommentModel.fromJson(json);
        return Either.right(CommentMapper.toDomain(model));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error adding comment'));
    }
  }

  // ───────────── REPLY COMMENT ─────────────

  Future<Either<Failure, ShortComment>> replyComment({
    required String parentCommentId,
    required String content,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.replyShortComment,
        data: {'parent_comment_id': parentCommentId, 'content': content},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final model = ShortCommentModel.fromJson(json);
        return Either.right(CommentMapper.toDomain(model));
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
