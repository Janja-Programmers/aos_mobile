import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/data/live_mapper.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class LiveApi {
  final ApiClient _client;

  static const _uuid = Uuid();

  LiveApi(this._client);

  // ================= START LIVE =================

  Future<Either<Failure, LiveJoinSession>> startLive({
    required String title,
    required String coverImage,
    required String coverMediaId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.startLiveEndpoint,
        data: {
          'title': title,
          'cover_image': coverImage,
          'live_cover_media': coverMediaId,
        },
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final payload = asJsonMap(result.rightOrNull);

      final data = payload['data'];

      if (data == null || data is! Map) {
        return Either.left(
          const Failure('Invalid start live response: missing data'),
        );
      }

      final sessionJson = data['session'];

      if (sessionJson == null || sessionJson is! Map) {
        return Either.left(
          const Failure('Invalid start live response: missing session'),
        );
      }

      final sessionMap = asJsonMap(sessionJson);
      final session = mapJoinSession(sessionMap);

      return Either.right(session);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e) {
      return Either.left(Failure(e.toString(), type: FailureType.unknown));
    }
  }

  // ================= JOIN LIVE =================

  Future<Either<Failure, LiveJoinSession>> joinLive({
    required String liveId,
  }) async {
    try {
      final clientSessionId = _uuid.v4();
      final res = await _client.post(
        ApiEndpoints.joinLiveEndpoint,
        data: {'live_id': liveId, 'session_id': clientSessionId},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final payload = asJsonMap(result.rightOrNull);

      final data = payload['data'];
      if (data == null || data is! Map) {
        return Either.left(
          const Failure('Invalid join live response: missing data'),
        );
      }

      final sessionJson = data['session'];
      if (sessionJson == null || sessionJson is! Map) {
        return Either.left(
          const Failure('Invalid join live response: missing session'),
        );
      }

      final sessionMap = asJsonMap(sessionJson);
      sessionMap['session_id'] ??= clientSessionId;

      final session = mapJoinSession(sessionMap);

      return Either.right(session);
    } catch (e) {
      return Either.left(Failure(e.toString()));
    }
  }

  // ================= END LIVE =================

  Future<Either<Failure, void>> endLive({required String liveId}) async {
    appLogger.i('endLive API');

    try {
      final res = await _client.post(
        ApiEndpoints.endLiveEndpoint,
        data: {'live_id': liveId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } catch (e) {
      return Either.left(Failure(e.toString()));
    }
  }

  // ================= GET LIVE =================

  Future<Either<Failure, LiveStream>> getLive({required String liveId}) async {
    appLogger.i('getLive API');

    final res = await _client.get(
      ApiEndpoints.getLiveEndpoint,
      queryParameters: {'live_id': liveId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final data = asJsonMap(result.rightOrNull)['data'];
    if (data == null) {
      return Either.left(const Failure('Invalid live response'));
    }

    return Either.right(mapLiveStream(asJsonMap(data)));
  }

  // ================= LIST LIVE STREAMS =================

  Future<Either<Failure, List<LiveStream>>> listLives({
    int start = 0,
    int limit = 20,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listLiveStreamsEndpoint,
        queryParameters: {'start': start, 'limit': limit},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = asJsonMap(asJsonMap(result.rightOrNull)['data']);
      final items = asJsonMapList(data['items']);

      final lives = items.map(mapLiveStream).toList(growable: false);

      return Either.right(lives);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('listLives failed', error: e, stackTrace: s);

      return Either.left(
        const Failure(
          'Failed to fetch live streams.',
          type: FailureType.unknown,
        ),
      );
    }
  }

  /* METRICS  */

  // ================= TRACK JOIN =================

  Future<Either<Failure, String?>> trackJoin({
    required String liveId,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.trackLiveJoinEndpoint,
        data: {
          'live_id': liveId,
          if (sessionId?.isNotEmpty ?? false) 'session_id': sessionId,
        },
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = asJsonMap(asJsonMap(result.rightOrNull)['data']);
      final viewId = asNullableString(data['view_id']);

      return Either.right(viewId);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('trackJoin failed', error: e, stackTrace: s);
      return Either.left(
        const Failure('Failed to track live join.', type: FailureType.unknown),
      );
    }
  }

  // ================= TRACK LEAVE =================

  Future<Either<Failure, void>> trackLeave({
    required String liveId,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.trackLiveLeaveEndpoint,
        data: {
          'live_id': liveId,
          if (sessionId?.isNotEmpty ?? false) 'session_id': sessionId,
        },
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('trackLeave failed', error: e, stackTrace: s);
      return Either.left(
        const Failure('Failed to track live leave.', type: FailureType.unknown),
      );
    }
  }

  /* REACTIONS */
  // ================= SEND REACTION =================

  Future<Either<Failure, void>> sendReaction({
    required String liveId,
    required String reactionType,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.sendLiveReaction,
        data: {
          'live_id': liveId,
          'reaction_type': reactionType,
          if (sessionId?.isNotEmpty ?? false) 'session_id': sessionId,
        },
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('sendReaction failed', error: e, stackTrace: s);

      return Either.left(
        const Failure('Failed to send reaction.', type: FailureType.unknown),
      );
    }
  }
}
