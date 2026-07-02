import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/connect/calls/data/call_api.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';

abstract class CallRepository {
  Future<String> openConversation({required String userId});

  Future<Call> initiateCall({
    required String conversationId,
    required AOSCallType callType,
  });

  Future<void> markCallRinging({required String callId});

  Future<void> cancelCall({required String callId});

  Future<Call> acceptCall({required String callId});

  Future<void> rejectCall({required String callId});

  Future<void> endCall({required String callId});

  Future<List<CallLog>> listCalls({String? type});

  Future<List<CallLog>> getCallGroupDetail({required CallLog call});

  Future<void> deleteCallLogs({required List<String> callIds});

  Future<int> clearCallHistory();

  Future<Call> requestVideoUpgrade({required String callId});

  Future<Call> respondVideoUpgrade({
    required String callId,
    required String action,
  });

  Future<Map<String, dynamic>> getCallStatus({required String callId});

  Future<Call> getCallToken({required String callId});
}

class CallRepositoryImpl implements CallRepository {
  final CallApi api;

  const CallRepositoryImpl(this.api);

  // -----------------------------
  // Conversation
  // -----------------------------
  @override
  Future<String> openConversation({required String userId}) async {
    final res = await api.openConversation(userId);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Initiate Call
  // -----------------------------
  @override
  Future<Call> initiateCall({
    required String conversationId,
    required AOSCallType callType,
  }) async {
    final res = await api.initiateCall(
      conversationId: conversationId,
      callType: callType.name,
    );

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Mark Call Ringing
  // -----------------------------
  @override
  Future<void> markCallRinging({required String callId}) async {
    final res = await api.markCallRinging(callId: callId);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Cancel Call
  // -----------------------------
  @override
  Future<void> cancelCall({required String callId}) async {
    final res = await api.cancelCall(callId: callId);

    return res.fold((e) => throw e, (_) => null);
  }

  // -----------------------------
  // Accept Call
  // -----------------------------
  @override
  Future<Call> acceptCall({required String callId}) async {
    final res = await api.acceptCall(callId: callId);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Reject Call
  // -----------------------------
  @override
  Future<void> rejectCall({required String callId}) async {
    final res = await api.rejectCall(callId: callId);

    return res.fold((e) => throw e, (_) => null);
  }

  // -----------------------------
  // End Call
  // -----------------------------
  @override
  Future<void> endCall({required String callId}) async {
    final res = await api.endCall(callId: callId);

    return res.fold((e) => throw e, (_) => null);
  }

  // -----------------------------
  // List Calls
  // -----------------------------
  @override
  Future<List<CallLog>> listCalls({String? type}) async {
    final res = await api.listCalls(type: type);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Get Call Group Detail
  // -----------------------------
  @override
  Future<List<CallLog>> getCallGroupDetail({required CallLog call}) async {
    final res = await api.getCallGroupDetail(call: call);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Delete Call Log(s)
  // -----------------------------
  @override
  Future<void> deleteCallLogs({required List<String> callIds}) async {
    final res = await api.deleteCallLogs(callIds: callIds);

    return res.fold((e) => throw e, (_) => null);
  }

  // -----------------------------
  // Clear Call History
  // -----------------------------
  @override
  Future<int> clearCallHistory() async {
    final res = await api.clearCallHistory();

    return res.fold((e) => throw e, (deletedCount) => deletedCount);
  }

  // -----------------------------
  // Request Video Upgrade
  // -----------------------------
  @override
  Future<Call> requestVideoUpgrade({required String callId}) async {
    final res = await api.requestVideoUpgrade(callId: callId);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Respond Video Upgrade
  // -----------------------------
  @override
  Future<Call> respondVideoUpgrade({
    required String callId,
    required String action,
  }) async {
    final res = await api.respondVideoUpgrade(callId: callId, action: action);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Get Call Status
  // -----------------------------
  @override
  Future<Map<String, dynamic>> getCallStatus({required String callId}) async {
    final res = await api.getCallStatus(callId: callId);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Get Token
  // -----------------------------
  @override
  Future<Call> getCallToken({required String callId}) async {
    final res = await api.getCallToken(callId: callId);

    return res.fold((e) => throw e, (data) {
      return Call(
        id: callId,
        conversationId: '',
        callType: AOSCallType.audio,
        roomName: asString(data['room_name']),
        token: asString(data['token']),
        wsUrl: asString(data['ws_url']),
      );
    });
  }
}
