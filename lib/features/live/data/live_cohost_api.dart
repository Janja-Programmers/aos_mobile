import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/live/data/live_mapper.dart';
import 'package:africaonlinestores/features/live/domain/live_cohost.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';

final liveCohostApiProvider = Provider<LiveCohostApi>((ref) {
  return LiveCohostApi(ref.read(apiClientProvider));
});

class LiveCohostApi {
  final ApiClient _client;

  const LiveCohostApi(this._client);

  Future<Either<Failure, LiveCohost>> requestCohost({
    required String liveId,
    String? sessionId,
  }) {
    return _cohostPost(ApiEndpoints.requestLiveCohost, {
      'live_id': liveId,
      if (sessionId?.isNotEmpty == true) 'session_id': sessionId,
    });
  }

  Future<Either<Failure, LiveCohost>> inviteCohost({
    required String liveId,
    required String targetUser,
    String? sessionId,
  }) {
    return _cohostPost(ApiEndpoints.inviteLiveCohost, {
      'live_id': liveId,
      'target_user': targetUser,
      if (sessionId?.isNotEmpty == true) 'session_id': sessionId,
    });
  }

  Future<Either<Failure, LiveCohost>> respondCohost({
    required String cohostId,
    required bool accept,
    String? reason,
  }) {
    return _cohostPost(ApiEndpoints.respondLiveCohost, {
      'cohost_id': cohostId,
      'action': accept ? 'accept' : 'reject',
      if (reason?.trim().isNotEmpty == true) 'reason': reason!.trim(),
    });
  }

  Future<Either<Failure, LiveCohost>> activateCohost({
    required String cohostId,
    String? sessionId,
  }) {
    return _cohostPost(ApiEndpoints.activateLiveCohost, {
      'cohost_id': cohostId,
      if (sessionId?.isNotEmpty == true) 'session_id': sessionId,
    });
  }

  Future<Either<Failure, void>> endCohost({required String cohostId}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.endLiveCohost,
        data: {'cohost_id': cohostId},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to end co-host.'));
    }
  }

  Future<Either<Failure, List<LiveCohost>>> listCohosts({
    required String liveId,
    String? status,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listLiveCohosts,
        queryParameters: {
          'live_id': liveId,
          if (status?.isNotEmpty == true) 'status': status,
        },
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final data = unwrapped.rightOrNull?['data'];
      final rawItems = data is Map ? data['items'] : null;
      return Either.right(
        rawItems is List
            ? rawItems
                  .whereType<Map>()
                  .map((e) => LiveCohost.fromJson(Map<String, dynamic>.from(e)))
                  .toList()
            : const [],
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load co-hosts.'));
    }
  }

  Future<Either<Failure, LiveJoinSession>> getCohostToken({
    required String cohostId,
    String? sessionId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.getLiveCohostToken,
        data: {
          'cohost_id': cohostId,
          if (sessionId?.isNotEmpty == true) 'session_id': sessionId,
        },
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final data = unwrapped.rightOrNull?['data'];
      final session = data is Map ? data['session'] ?? data : null;
      if (session is! Map) {
        return Either.left(const Failure('Invalid co-host token response.'));
      }
      return Either.right(
        mapJoinSession(
          Map<String, dynamic>.from(session),
          role: AOSLiveRole.host,
        ),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to get co-host token.'));
    }
  }

  Future<Either<Failure, LiveCohost>> _cohostPost(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.post(endpoint, data: data);
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final payload = unwrapped.rightOrNull?['data'];
      final raw = payload is Map ? payload['cohost'] : null;
      if (raw is! Map) {
        return Either.left(const Failure('Invalid co-host response.'));
      }
      return Either.right(LiveCohost.fromJson(Map<String, dynamic>.from(raw)));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update co-host.'));
    }
  }
}
