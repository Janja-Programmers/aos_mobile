import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/data/live_mapper.dart';
import 'package:africaonlinestores/features/live/domain/live_bootstrap.dart';
import 'package:africaonlinestores/features/live/domain/live_list_page.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class LiveApi {
  LiveApi(this._client);

  static const Uuid _uuid = Uuid();

  final ApiClient _client;

  Future<Either<Failure, LiveBootstrap>> startLive({
    required String title,
    String? coverImage,
    String? coverMediaId,
  }) async {
    final cleanTitle = title.trim();
    final cleanMediaId = coverMediaId?.trim() ?? '';
    final cleanCoverImage = coverImage?.trim() ?? '';

    try {
      final response = await _client.post(
        ApiEndpoints.startLiveEndpoint,
        data: <String, dynamic>{
          'title': cleanTitle,
          if (cleanMediaId.isNotEmpty) 'live_cover_media': cleanMediaId,
          if (cleanMediaId.isEmpty && cleanCoverImage.isNotEmpty)
            'cover_image': cleanCoverImage,
        },
      );
      final unwrapped = unwrapFrappe(response);

      return unwrapped.fold(
        Either.left,
        (payload) => _parseBootstrap(payload, operation: 'start'),
      );
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'startLive response parsing failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(
        const Failure('Invalid start Live response.', type: FailureType.parse),
      );
    }
  }

  Future<Either<Failure, LiveBootstrap>> joinLive({
    required String liveId,
    String? sessionId,
  }) async {
    final clientSessionId = sessionId?.trim().isNotEmpty ?? false
        ? sessionId!.trim()
        : _uuid.v4();

    try {
      final response = await _client.post(
        ApiEndpoints.joinLiveEndpoint,
        data: <String, dynamic>{
          'live_id': liveId,
          'session_id': clientSessionId,
        },
      );
      final unwrapped = unwrapFrappe(response);

      return unwrapped.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final rawSession = data['session'];
        if (rawSession is Map<Object?, Object?>) {
          final session = asJsonMap(rawSession);
          session['session_id'] ??= clientSessionId;
          data['session'] = session;
        }
        return _parseBootstrapData(data, operation: 'join');
      });
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'joinLive response parsing failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(
        const Failure('Invalid join Live response.', type: FailureType.parse),
      );
    }
  }

  Future<Either<Failure, LiveStream>> getLive({
    required String liveId,
    String? sessionId,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.getLiveEndpoint,
        queryParameters: <String, dynamic>{
          'live_id': liveId,
          if (sessionId?.trim().isNotEmpty ?? false)
            'session_id': sessionId!.trim(),
        },
      );
      final unwrapped = unwrapFrappe(response);

      return unwrapped.fold(
        Either.left,
        (payload) => _parseLivePayload(payload, operation: 'detail'),
      );
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object {
      return Either.left(
        const Failure('Invalid Live detail response.', type: FailureType.parse),
      );
    }
  }

  Future<Either<Failure, LiveListPage>> listLives({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.listLiveStreamsEndpoint,
        queryParameters: <String, dynamic>{
          'limit': limit,
          if (cursor?.trim().isNotEmpty ?? false) 'cursor': cursor!.trim(),
        },
      );
      final unwrapped = unwrapFrappe(response);

      return unwrapped.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final pagination = asJsonMap(data['pagination']);
        final items = asJsonMapList(
          data['items'],
        ).map(mapLiveStream).toList(growable: false);

        return Either.right(
          LiveListPage(
            items: items,
            nextCursor: asNullableString(pagination['next_cursor']),
            hasMore: pagination['has_more'] == true,
          ),
        );
      });
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e('listLives failed', error: error, stackTrace: stackTrace);
      return Either.left(
        const Failure(
          'Failed to fetch live streams.',
          type: FailureType.unknown,
        ),
      );
    }
  }

  Future<Either<Failure, LiveStream?>> trackJoin({
    required String liveId,
    required String sessionId,
  }) {
    return _track(
      endpoint: ApiEndpoints.trackLiveJoinEndpoint,
      liveId: liveId,
      sessionId: sessionId,
      operation: 'join',
    );
  }

  Future<Either<Failure, LiveStream?>> trackLeave({
    required String liveId,
    required String sessionId,
  }) {
    return _track(
      endpoint: ApiEndpoints.trackLiveLeaveEndpoint,
      liveId: liveId,
      sessionId: sessionId,
      operation: 'leave',
    );
  }

  Future<Either<Failure, LiveReaction>> sendReaction({
    required String liveId,
    required LiveReactionType reactionType,
    String? sessionId,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.sendLiveReaction,
        data: <String, dynamic>{
          'live_id': liveId,
          'reaction_type': reactionType.apiValue,
          if (sessionId?.trim().isNotEmpty ?? false)
            'session_id': sessionId!.trim(),
        },
      );
      final unwrapped = unwrapFrappe(response);

      return unwrapped.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final rawReaction = data['reaction'];
        if (rawReaction is! Map<Object?, Object?>) {
          return Either.left(
            const Failure(
              'Invalid Live reaction response.',
              type: FailureType.parse,
            ),
          );
        }
        final reaction = LiveReaction.fromJson(asJsonMap(rawReaction));
        if (reaction.id.isEmpty || reaction.liveId != liveId) {
          return Either.left(
            const Failure(
              'Invalid Live reaction response.',
              type: FailureType.parse,
            ),
          );
        }
        return Either.right(reaction);
      });
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object {
      return Either.left(
        const Failure('Failed to send reaction.', type: FailureType.unknown),
      );
    }
  }

  /// Ends the Live and preserves the backend's canonical final analytics
  /// snapshot instead of discarding `data.live`.
  Future<Either<Failure, LiveStream>> endLive({required String liveId}) async {
    try {
      final response = await _client.post(
        ApiEndpoints.endLiveEndpoint,
        data: <String, dynamic>{'live_id': liveId},
      );
      final unwrapped = unwrapFrappe(response);
      return unwrapped.fold(
        Either.left,
        (payload) => _parseLivePayload(
          payload,
          operation: 'end',
          expectedLiveId: liveId,
        ),
      );
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'endLive response parsing failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(
        const Failure('Invalid end Live response.', type: FailureType.parse),
      );
    }
  }

  Future<Either<Failure, void>> shareLiveToChat({
    required String liveId,
    required String conversationId,
    String? message,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.shareLiveToChat,
        data: <String, dynamic>{
          'live_id': liveId,
          'conversation_id': conversationId,
          if (message?.trim().isNotEmpty ?? false) 'message': message!.trim(),
          if (idempotencyKey?.trim().isNotEmpty ?? false)
            'idempotency_key': idempotencyKey!.trim(),
        },
      );
      final unwrapped = unwrapFrappe(response);
      return unwrapped.fold(Either.left, (_) => Either.right(null));
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object {
      return Either.left(const Failure('Failed to share Live to chat.'));
    }
  }

  Either<Failure, LiveBootstrap> _parseBootstrap(
    Map<String, dynamic> payload, {
    required String operation,
  }) {
    return _parseBootstrapData(
      asJsonMap(payload['data']),
      operation: operation,
    );
  }

  Either<Failure, LiveBootstrap> _parseBootstrapData(
    Map<String, dynamic> data, {
    required String operation,
  }) {
    try {
      return Either.right(mapLiveBootstrap(data));
    } on Object {
      return Either.left(
        Failure('Invalid $operation Live response.', type: FailureType.parse),
      );
    }
  }

  Either<Failure, LiveStream> _parseLivePayload(
    Map<String, dynamic> payload, {
    required String operation,
    String? expectedLiveId,
  }) {
    try {
      final data = asJsonMap(payload['data']);
      final rawLive = data['live'];
      if (rawLive is! Map<Object?, Object?>) {
        throw const FormatException('Missing Live payload.');
      }
      final live = mapLiveStream(asJsonMap(rawLive));
      if (live.id.isEmpty ||
          (expectedLiveId != null && live.id != expectedLiveId)) {
        throw const FormatException('Unexpected Live identifier.');
      }
      return Either.right(live);
    } on Object {
      return Either.left(
        Failure('Invalid Live $operation response.', type: FailureType.parse),
      );
    }
  }

  Future<Either<Failure, LiveStream?>> _track({
    required String endpoint,
    required String liveId,
    required String sessionId,
    required String operation,
  }) async {
    try {
      final response = await _client.post(
        endpoint,
        data: <String, dynamic>{'live_id': liveId, 'session_id': sessionId},
      );
      final unwrapped = unwrapFrappe(response);

      return unwrapped.fold(Either.left, (payload) {
        final data = asJsonMap(payload['data']);
        final rawLive = data['live'];
        if (rawLive is! Map<Object?, Object?>) return Either.right(null);
        return Either.right(mapLiveStream(asJsonMap(rawLive)));
      });
    } on DioException catch (error) {
      return Either.left(mapDioException(error));
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'track Live $operation failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either.left(Failure('Failed to track Live $operation.'));
    }
  }
}
