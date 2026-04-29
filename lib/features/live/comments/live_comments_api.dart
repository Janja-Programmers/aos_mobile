import 'package:africaonlinestores/core/providers.dart';
import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/live/comments/live_comment_model.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_mapper.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveCommentsApiProvider = Provider<LiveCommentsApi>((ref) {
  return LiveCommentsApi(ref.read(apiClientProvider));
});

class LiveCommentsApi {
  final ApiClient _client;

  LiveCommentsApi(this._client);

  // ───────────── LIST COMMENTS ─────────────

  Future<Either<Failure, List<LiveComment>>> listComments({
    required String liveId,
    String? cursor,
  }) async {
    try {
      final query = {
        'live_id': liveId,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      final res = await _client.get(
        ApiEndpoints.listLiveComments,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final rawItems = data['items'] as List? ?? [];

        final items = rawItems
            .map(
              (e) => LiveCommentMapper.toDomain(
                LiveCommentModel.fromJson(Map<String, dynamic>.from(e as Map)),
              ),
            )
            .toList();

        return Either.right(items);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error fetching live comments'),
      );
    }
  }

  // ───────────── LIST REPLIES ─────────────

  Future<Either<Failure, List<LiveComment>>> listReplies({
    required String rootCommentId,
    String? cursor,
  }) async {
    try {
      final query = {
        'root_comment_id': rootCommentId,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      final res = await _client.get(
        ApiEndpoints.listLiveReplies,
        queryParameters: query,
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final rawItems = data['items'] as List? ?? [];

        final items = rawItems
            .map(
              (e) => LiveCommentMapper.toDomain(
                LiveCommentModel.fromJson(Map<String, dynamic>.from(e as Map)),
              ),
            )
            .toList();

        return Either.right(items);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error fetching live replies'),
      );
    }
  }

  // ───────────── ADD COMMENT ─────────────

  Future<Either<Failure, LiveComment>> addComment({
    required String liveId,
    required String comment,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.addLiveComment,
        data: {'live_id': liveId, 'content': comment},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>?;

        if (data == null) {
          return Either.left(const Failure('Invalid live comment response'));
        }

        final commentId = data['comment_id']?.toString();

        if (commentId == null || commentId.isEmpty) {
          return Either.left(
            const Failure('Missing comment_id', type: FailureType.parse),
          );
        }

        final model = LiveCommentModel(
          id: commentId,
          liveId: liveId,
          userId: '',
          comment: comment,
          parentId: null,
          rootId: null,
          replyCount: 0,
          isDeleted: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        return Either.right(LiveCommentMapper.toDomain(model));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error adding live comment'));
    }
  }

  // ───────────── REPLY COMMENT ─────────────

  Future<Either<Failure, String>> replyComment({
    required String parentCommentId,
    required String comment,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.replyLiveComment,
        data: {'parent_comment_id': parentCommentId, 'content': comment},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold((failure) => Either.left(failure), (json) {
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final commentId = data['comment_id']?.toString();

        if (commentId == null || commentId.isEmpty) {
          return Either.left(
            const Failure('Invalid reply response', type: FailureType.parse),
          );
        }

        return Either.right(commentId);
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error replying to live comment'),
      );
    }
  }

  // ───────────── DELETE COMMENT ─────────────

  Future<Either<Failure, void>> deleteComment({
    required String commentId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteLiveComment,
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
      return Either.left(
        const Failure('Unexpected error deleting live comment'),
      );
    }
  }
}
