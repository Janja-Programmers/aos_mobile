import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_mapper.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveCommentsApiProvider = Provider<LiveCommentsApi>((ref) {
  return LiveCommentsApi(ref.read(apiClientProvider));
});

class LiveCommentsApi {
  final ApiClient _client;

  LiveCommentsApi(this._client);

  Future<Either<Failure, List<LiveComment>>> listComments({
    required String liveId,
    int start = 0,
    int limit = 80,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listLiveComments,
        queryParameters: {'live_id': liveId, 'start': start, 'limit': limit},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);
        final items = asJsonMapList(data['items'])
            .map(
              (Map<String, dynamic> item) =>
                  LiveCommentMapper.toDomain(LiveCommentModel.fromJson(item)),
            )
            .where((LiveComment item) => !item.isDeleted)
            .toList(growable: false);

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

  Future<Either<Failure, List<LiveComment>>> listReplies({
    required String parentMessageId,
    int start = 0,
    int limit = 40,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listLiveReplies,
        queryParameters: {
          'parent_message': parentMessageId,
          'start': start,
          'limit': limit,
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);
        final items = asJsonMapList(data['items'])
            .map(
              (Map<String, dynamic> item) =>
                  LiveCommentMapper.toDomain(LiveCommentModel.fromJson(item)),
            )
            .where((LiveComment item) => !item.isDeleted)
            .toList(growable: false);

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

  Future<Either<Failure, LiveComment>> addComment({
    required String liveId,
    required String comment,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.addLiveComment,
        data: {
          'live_id': liveId,
          'content': comment,
          if (sessionId?.isNotEmpty ?? false) 'session_id': sessionId,
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);
        final raw = data['message'];

        if (raw is! Map) {
          return Either.left(const Failure('Invalid live comment response'));
        }

        final model = LiveCommentModel.fromJson(asJsonMap(raw));
        if (model.id.isEmpty) {
          return Either.left(
            const Failure(
              'Invalid live comment response',
              type: FailureType.parse,
            ),
          );
        }

        return Either.right(LiveCommentMapper.toDomain(model));
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error adding live comment'));
    }
  }

  Future<Either<Failure, LiveComment>> replyComment({
    required String liveId,
    required String parentMessageId,
    required String comment,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.replyLiveComment,
        data: {
          'live_id': liveId,
          'parent_message': parentMessageId,
          'content': comment,
          if (sessionId?.isNotEmpty ?? false) 'session_id': sessionId,
        },
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (json) {
        final data = asJsonMap(json['data']);
        final raw = data['message'];

        if (raw is! Map) {
          return Either.left(
            const Failure('Invalid reply response', type: FailureType.parse),
          );
        }

        return Either.right(
          LiveCommentMapper.toDomain(LiveCommentModel.fromJson(asJsonMap(raw))),
        );
      });
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error replying to live comment'),
      );
    }
  }

  Future<Either<Failure, void>> deleteComment({
    required String commentId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteLiveComment,
        data: {'message_id': commentId},
      );

      final unwrapped = unwrapFrappe(res);

      return unwrapped.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(
        const Failure('Unexpected error deleting live comment'),
      );
    }
  }
}
