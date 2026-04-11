import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/live/data/live_mapper.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';

class LiveApi {
  final ApiClient _client;

  LiveApi(this._client);

  // ================= START LIVE =================
  Future<Either<Failure, LiveJoinSession>> startLive({
    required String title,
  }) async {
    appLogger.i("startLive API");

    try {
      final res = await _client.post(
        ApiEndpoints.startLiveEndpoint,
        data: {'title': title},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = result.rightOrNull?['data'];
      if (data == null) {
        return Either.left(const Failure("Invalid start live response"));
      }

      return Either.right(mapJoinSession(data, role: AOSLiveRole.host));
    } catch (e) {
      return Either.left(Failure(e.toString()));
    }
  }

  // ================= JOIN LIVE =================
  Future<Either<Failure, LiveJoinSession>> joinLive({
    required String liveId,
  }) async {
    appLogger.i("joinLive API");

    try {
      final res = await _client.post(
        ApiEndpoints.joinLiveEndpoint,
        data: {'live_id': liveId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = result.rightOrNull?['data'];
      if (data == null) {
        return Either.left(const Failure("Invalid join live response"));
      }

      final role = data['role'] == 'host'
          ? AOSLiveRole.host
          : AOSLiveRole.viewer;

      return Either.right(mapJoinSession(data, role: role));
    } catch (e) {
      return Either.left(Failure(e.toString()));
    }
  }

  // ================= END LIVE =================
  Future<Either<Failure, void>> endLive({required String liveId}) async {
    appLogger.i("endLive API");

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
    appLogger.i("getLive API");

    final res = await _client.get(
      ApiEndpoints.getLiveEndpoint,
      queryParameters: {'live_id': liveId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final data = result.rightOrNull?['data'];
    if (data == null) {
      return Either.left(const Failure("Invalid live response"));
    }

    return Either.right(mapLiveStream(data));
  }
}
