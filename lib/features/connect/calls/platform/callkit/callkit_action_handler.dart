import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';

class CallKitActionHandler {
  final CallManager callManager;

  const CallKitActionHandler({required this.callManager});

  Future<void> onAccept({required String? callId}) async {
    final activeCallId = callManager.currentState.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Ignoring CallKit accept: eventCallId=$callId activeCallId=$activeCallId',
      );
      return;
    }

    await callManager.acceptIncomingCall();
  }

  Future<void> onDecline({required String? callId}) async {
    final activeCallId = callManager.currentState.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Ignoring CallKit decline: eventCallId=$callId activeCallId=$activeCallId',
      );
      return;
    }

    await callManager.rejectIncomingCall();
  }

  Future<void> onEnded({required String? callId}) async {
    final activeCallId = callManager.currentState.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Ignoring CallKit end: eventCallId=$callId activeCallId=$activeCallId',
      );
      return;
    }

    await callManager.endCurrentCall();
  }

  Future<void> onTimeout({required String? callId}) async {
    final activeCallId = callManager.currentState.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Ignoring CallKit timeout: eventCallId=$callId activeCallId=$activeCallId',
      );
      return;
    }

    await callManager.callNotAnswered();
  }

  bool _matchesActiveCall(String? eventCallId, String? activeCallId) {
    if (activeCallId == null || activeCallId.isEmpty) return false;
    if (eventCallId == null || eventCallId.isEmpty) return true;

    return eventCallId == activeCallId;
  }
}
