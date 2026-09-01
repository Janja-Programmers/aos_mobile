import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_mapper.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_model.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveCommentsApiProvider = Provider<LiveCommentsApi>((ref) {
  return LiveCommentsApi(ref.read(apiClientProvider));
});

class LiveCommentsApi {
  LiveCommentsApi(this._client);

  final ApiClient _client;

  Future<Either<Failure, LiveCommentsPage>> listComments({
    required String liveId,
    int limit = 50,
    String? cursor,
    bool includeReplies = true,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listLiveComments,
        queryParameters: <String, dynamic>{
          'live_id': liveId,
          'limit': limit.clamp(1, 50),
          'include_replies': includeReplies ? 1 : 0,
          if (cursor?.trim().isNotEmpty ?? false) 'cursor': cursor!.trim(),
        },
      );
      return _parsePage(res, operation: 'live comments');
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'listComments response failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(
        const Failure('Unexpected error fetching live comments'),
      );
    }
  }

  Future<Either<Failure, LiveCommentsPage>> listReplies({
    required String parentMessageId,
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listLiveReplies,
        queryParameters: <String, dynamic>{
          'parent_message': parentMessageId,
          'limit': limit.clamp(1, 100),
          if (cursor?.trim().isNotEmpty ?? false) 'cursor': cursor!.trim(),
        },
      );
      return _parsePage(res, operation: 'live replies');
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'listReplies response failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(const Failure('Unexpected error fetching replies'));
    }
  }

  Future<Either<Failure, LiveComment>> addComment({
    required String liveId,
    required String comment,
    String? sessionId,
    String? idempotencyKey,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.addLiveComment,
        data: <String, dynamic>{
          'live_id': liveId,
          'content': comment,
          if (sessionId?.trim().isNotEmpty ?? false)
            'session_id': sessionId!.trim(),
          if (idempotencyKey?.trim().isNotEmpty ?? false)
            'idempotency_key': idempotencyKey!.trim(),
        },
      );
      return _parseMessage(res, operation: 'live comment');
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'addComment response failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(const Failure('Unexpected error adding live comment'));
    }
  }

  Future<Either<Failure, LiveComment>> replyComment({
    required String liveId,
    required String parentMessageId,
    required String comment,
    String? sessionId,
    String? idempotencyKey,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.replyLiveComment,
        data: <String, dynamic>{
          'live_id': liveId,
          'parent_message': parentMessageId,
          'content': comment,
          if (sessionId?.trim().isNotEmpty ?? false)
            'session_id': sessionId!.trim(),
          if (idempotencyKey?.trim().isNotEmpty ?? false)
            'idempotency_key': idempotencyKey!.trim(),
        },
      );
      return _parseMessage(res, operation: 'live reply');
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'replyComment response failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(const Failure('Unexpected error replying to comment'));
    }
  }

  Future<Either<Failure, Set<String>>> deleteComment({
    required String commentId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteLiveComment,
        data: <String, dynamic>{'message_id': commentId},
      );
      final unwrapped = unwrapFrappe(res);
      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);
        final ids = <String>{};
        for (final raw in asJsonList(data['deleted_message_ids'])) {
          final id = raw?.toString().trim() ?? '';
          if (id.isNotEmpty) ids.add(id);
        }
        final single = data['message_id']?.toString().trim() ?? '';
        if (single.isNotEmpty) ids.add(single);
        if (ids.isEmpty) ids.add(commentId);
        return Either.right(ids);
      });
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'deleteComment response failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(const Failure('Unexpected error deleting comment'));
    }
  }

  Either<Failure, LiveCommentsPage> _parsePage(
    Response<dynamic> response, {
    required String operation,
  }) {
    final unwrapped = unwrapFrappe(response);
    return unwrapped.fold(Either.left, (json) {
      try {
        final data = asJsonMap(json['data']);
        final pagination = asJsonMap(data['pagination']);
        final items = asJsonMapList(data['items'])
            .map(LiveCommentModel.fromJson)
            .map(LiveCommentMapper.toDomain)
            .where((item) => !item.isDeleted)
            .toList(growable: false);
        return Either.right(
          LiveCommentsPage(
            items: items,
            nextCursor: asNullableString(pagination['next_cursor']),
            hasMore: pagination['has_more'] == true,
          ),
        );
      } on Object catch (error, stackTrace) {
        appLogger.e(
          'Invalid $operation response',
          error: error,
          stackTrace: stackTrace,
        );
        return Either.left(
          Failure('Invalid $operation response.', type: FailureType.parse),
        );
      }
    });
  }

  Either<Failure, LiveComment> _parseMessage(
    Response<dynamic> response, {
    required String operation,
  }) {
    final unwrapped = unwrapFrappe(response);
    return unwrapped.fold(Either.left, (json) {
      final data = asJsonMap(json['data']);
      final raw = data['message'];
      if (raw is! Map<Object?, Object?>) {
        return Either.left(
          Failure('Invalid $operation response.', type: FailureType.parse),
        );
      }
      final model = LiveCommentModel.fromJson(asJsonMap(raw));
      if (model.id.isEmpty) {
        return Either.left(
          Failure('Invalid $operation response.', type: FailureType.parse),
        );
      }
      return Either.right(LiveCommentMapper.toDomain(model));
    });
  }
}
