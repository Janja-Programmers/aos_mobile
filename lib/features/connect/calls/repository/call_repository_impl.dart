import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/data/call_api.dart';
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
        roomName: data['room_name'] ?? '',
        token: data['token'] ?? '',
        wsUrl: data['ws_url'] ?? '',
        caller: null,
        receiver: null,
      );
    });
  }
}
