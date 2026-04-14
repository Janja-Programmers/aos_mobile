import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

class CallSignalingHandler {
  final CallManager callManager;

  const CallSignalingHandler({required this.callManager});

  // ================= INCOMING =================
  Future<void> handleIncomingCall(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;
      final callerRaw = data['caller'] as String?;
      final roomName = data['room_name'] as String?;
      final callTypeRaw = data['call_type'] as String?;

      if (callId == null || roomName == null || callTypeRaw == null) {
        appLogger.e('❌ Invalid incoming call payload: $data');
        return;
      }

      final callType = callTypeRaw == 'video'
          ? AOSCallType.video
          : AOSCallType.audio;

      final caller = callerRaw != null
          ? CallParticipant(
              userId: callerRaw,
              displayName: callerRaw,
              avatarUrl: null,
            )
          : null;

      appLogger.i('📞 Incoming call parsed');

      await callManager.onIncomingCallEvent(
        callId: callId,
        roomName: roomName,
        callType: callType,
        caller: caller,
      );
    } catch (e, s) {
      appLogger.e('handleIncomingCall failed', error: e, stackTrace: s);
    }
  }

  // ================= ACCEPTED =================
  Future<void> handleCallAccepted(Map<String, dynamic> data) async {
    try {
      appLogger.i("CallManager: handleCallAccepted | Data: ${data.toString()}");
      final callId = data['call_id'] as String?;
      final token = data['token'] as String?;
      final wsUrl = data['ws_url'] as String?;

      if (callId == null || token == null || wsUrl == null) {
        appLogger.e('❌ Invalid call accepted payload: $data');
        return;
      }

      appLogger.i('✅ Call accepted parsed');

      await callManager.onCallAcceptedEvent(
        callId: callId,
        token: token,
        wsUrl: wsUrl,
      );
    } catch (e, s) {
      appLogger.e('handleCallAccepted failed', error: e, stackTrace: s);
    }
  }

  // ================= REJECTED =================
  Future<void> handleCallRejected(Map<String, dynamic> data) async {
    appLogger.i(' handleCallRejectSignal | Data: ${data.toString()}');

    try {
      final callId = data['call_id'] as String?;

      if (callId == null) {
        appLogger.e('❌ Invalid call rejected payload: $data');
        return;
      }

      appLogger.i('❌ Call rejected parsed');

      await callManager.onCallRejectedEvent(callId: callId);
    } catch (e, s) {
      appLogger.e('handleCallRejected failed', error: e, stackTrace: s);
    }
  }

  // ================= ENDED =================
  Future<void> handleCallEnded(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;

      if (callId == null) {
        appLogger.e('❌ Invalid call ended payload: $data');
        return;
      }

      appLogger.i('🔚 Call ended parsed');

      await callManager.onCallEndedEvent(callId: callId);
    } catch (e, s) {
      appLogger.e('handleCallEnded failed', error: e, stackTrace: s);
    }
  }

  // ================= HANDLECALLNOTANSWERED =================
  Future<void> handleCallNotAnswered(Map<String, dynamic> data) async {
    try {
      final callId = data['call_id'] as String?;

      if (callId == null) {
        appLogger.e('❌ Invalid not-answered payload: $data');
        return;
      }

      await callManager.onCallNotAnswered(callId: callId);
    } catch (e, s) {
      appLogger.e('handleCallNotAnswered failed', error: e, stackTrace: s);
    }
  }
}
