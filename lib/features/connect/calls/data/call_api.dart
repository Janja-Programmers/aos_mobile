import 'package:dio/dio.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/data/call_mapper.dart';

class CallApi {
  final ApiClient _client;

  CallApi(this._client);

  // -----------------------------
  // Conversation
  // -----------------------------
  Future<Either<Failure, String>> openConversation(String user) async {
    appLogger.i("openConversation (Call)");

    final res = await _client.post(
      ApiEndpoints.openConversationEndpoint,
      data: {'user': user},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final payload = result.rightOrNull!;
    final id = payload['data']?['id'];

    if (id == null) {
      return Either.left(const Failure("Invalid conversation response"));
    }

    return Either.right(id.toString());
  }

  // -----------------------------
  // Initiate Call
  // -----------------------------
  Future<Either<Failure, Call>> initiateCall({
    required String conversationId,
    required String callType,
  }) async {
    appLogger.i("initiateCall API");

    try {
      final res = await _client.post(
        ApiEndpoints.initiateCallEndpoint,
        data: {'conversation_id': conversationId, 'call_type': callType},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = result.rightOrNull?['data'];
      if (data == null) {
        return Either.left(const Failure("Invalid initiate call response"));
      }

      return Either.right(mapCall(data));
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;

        final result = unwrapFrappe(res);
        if (result.isRight) {
          final data = result.rightOrNull?['data'];
          if (data != null) {
            return Either.right(mapCall(data));
          }
        }

        return Either.left(Failure(res.data.toString()));
      }

      return Either.left(Failure(e.toString()));
    }
  }

  // -----------------------------
  // Mark Call as Ringing
  // -----------------------------
  Future<Either<Failure, void>> markCallRinging({
    required String callId,
  }) async {
    appLogger.i("markCallRinging API");

    try {
      final res = await _client.post(
        ApiEndpoints.markCallRingingEndpoint,
        data: {'call_id': callId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;

        final result = unwrapFrappe(res);
        if (result.isLeft) return Either.left(result.leftOrNull!);
      }

      return Either.left(Failure(e.toString()));
    }
  }

  // -----------------------------
  // Cancel Call
  // -----------------------------
  Future<Either<Failure, void>> cancelCall({required String callId}) async {
    appLogger.i("cancelCall API");

    try {
      final res = await _client.post(
        ApiEndpoints.cancelCallEndpoint,
        data: {'call_id': callId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;

        final result = unwrapFrappe(res);
        if (result.isLeft) return Either.left(result.leftOrNull!);
      }

      return Either.left(Failure(e.toString()));
    }
  }

  // -----------------------------
  // Accept Call
  // -----------------------------
  Future<Either<Failure, Call>> acceptCall({required String callId}) async {
    appLogger.i("acceptCall API");

    try {
      final res = await _client.post(
        ApiEndpoints.acceptCallEndpoint,
        data: {'call_id': callId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = result.rightOrNull?['data'];
      if (data == null) {
        return Either.left(const Failure("Invalid accept call response"));
      }

      return Either.right(mapCall(data));
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;

        final result = unwrapFrappe(res);
        if (result.isRight) {
          final data = result.rightOrNull?['data'];
          if (data != null) {
            return Either.right(mapCall(data));
          }
        }

        return Either.left(Failure(res.data.toString()));
      }

      return Either.left(Failure(e.toString()));
    }
  }

  // -----------------------------
  // Reject Call
  // -----------------------------
  Future<Either<Failure, void>> rejectCall({required String callId}) async {
    appLogger.i("rejectCall API");

    try {
      final res = await _client.post(
        ApiEndpoints.rejectCallEndpoint,
        data: {'call_id': callId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;

        final result = unwrapFrappe(res);
        if (result.isLeft) return Either.left(result.leftOrNull!);
      }

      return Either.left(Failure(e.toString()));
    }
  }

  // -----------------------------
  // End Call
  // -----------------------------
  Future<Either<Failure, void>> endCall({required String callId}) async {
    appLogger.i("endCall API");

    try {
      final res = await _client.post(
        ApiEndpoints.endCallEndpoint,
        data: {'call_id': callId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;

        final result = unwrapFrappe(res);
        if (result.isLeft) return Either.left(result.leftOrNull!);
      }

      return Either.left(Failure(e.toString()));
    }
  }

  // -----------------------------
  // List Calls
  // -----------------------------
  Future<Either<Failure, List<CallLog>>> listCalls({String? type}) async {
    appLogger.i("listCalls API");

    try {
      final res = await _client.get(
        ApiEndpoints.listCallsEndpoint,
        queryParameters: type != null ? {'type': type} : null,
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final raw = result.rightOrNull;
      final List<dynamic> dataList = (raw?['data'] is List) ? raw!['data'] : [];

      final calls = dataList
          .whereType<Map<String, dynamic>>()
          .map(mapCallLog)
          .toList();

      calls.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Either.right(calls);
    } catch (e, s) {
      appLogger.e("listCalls failed", error: e, stackTrace: s);
      return Either.left(const Failure("Failed to load calls"));
    }
  }

  // -----------------------------
  // Get Call Status
  // -----------------------------
  Future<Either<Failure, Map<String, dynamic>>> getCallStatus({
    required String callId,
  }) async {
    appLogger.i("getCallStatus API");

    try {
      final res = await _client.post(
        ApiEndpoints.getCallStatusEndpoint,
        data: {'call_id': callId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = result.rightOrNull?['data'];

      if (data is Map<String, dynamic>) {
        return Either.right(data);
      }

      if (data is Map) {
        return Either.right(
          data.map((key, value) => MapEntry(key.toString(), value)),
        );
      }

      return Either.left(const Failure("Invalid call status response"));
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;
        final result = unwrapFrappe(res);
        if (result.isLeft) return Either.left(result.leftOrNull!);

        return Either.left(Failure(res.data.toString()));
      }

      return Either.left(Failure(e.toString()));
    }
  }

  // -----------------------------
  // Get Call Token (partial data)
  // -----------------------------
  Future<Either<Failure, Map<String, dynamic>>> getCallToken({
    required String callId,
  }) async {
    appLogger.i("getCallToken API");

    final res = await _client.post(
      ApiEndpoints.getCallTokenEndpoint,
      data: {'call_id': callId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final data = result.rightOrNull?['data'];

    if (data == null) {
      return Either.left(const Failure("Invalid token response"));
    }

    return Either.right(Map<String, dynamic>.from(data as Map));
  }
}
