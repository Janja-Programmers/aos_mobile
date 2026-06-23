import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

class CallKitActionHandler {
  final CallManager callManager;

  const CallKitActionHandler({required this.callManager});

  Future<void> onAccept({required String? callId}) async {
    await _hydrateIfNeeded(callId);

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Ignoring CallKit accept: eventCallId=$callId activeCallId=$activeCallId',
      );
      return;
    }

    if (!_canAccept(snapshot)) {
      appLogger.i(
        '📞 Ignoring CallKit accept for non-ringing/terminal call: '
        'phase=${snapshot.uiPhase} status=${snapshot.backendStatus}',
      );
      return;
    }

    await callManager.acceptIncomingCall(expectedCallId: callId);
  }

  Future<void> onDecline({required String? callId}) async {
    await _hydrateIfNeeded(callId);

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Ignoring CallKit decline: eventCallId=$callId activeCallId=$activeCallId',
      );
      return;
    }

    if (!_isIncomingRinging(snapshot)) {
      return;
    }

    await callManager.rejectIncomingCall(expectedCallId: callId);
  }

  Future<void> onEnded({required String? callId}) async {
    await _hydrateIfNeeded(callId);

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      return;
    }

    if (_isTerminal(snapshot.backendStatus)) {
      return;
    }

    if (_isIncomingRinging(snapshot)) {
      await callManager.rejectIncomingCall(expectedCallId: callId);
      return;
    }

    if (!_canEndOrCancel(snapshot)) {
      return;
    }

    await callManager.endCurrentCall(expectedCallId: callId);
  }

  Future<void> onTimeout({required String? callId}) async {
    await _hydrateIfNeeded(callId);

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      return;
    }

    if (!_isIncomingRinging(snapshot)) {
      return;
    }

    await callManager.callNotAnswered(expectedCallId: callId);
  }

  Future<void> _hydrateIfNeeded(String? callId) async {
    final normalizedCallId = callId?.trim();
    if (normalizedCallId == null || normalizedCallId.isEmpty) return;

    final snapshot = callManager.currentState;
    if (snapshot.activeCall?.id == normalizedCallId) return;

    final hydrated = await callManager.ensureIncomingCallHydrated(
      callId: normalizedCallId,
    );

    if (hydrated) {
      appLogger.i(
        '📞 Hydrated CallManager from CallKit event: $normalizedCallId',
      );
    }
  }

  bool _matchesActiveCall(String? eventCallId, String? activeCallId) {
    if (activeCallId == null || activeCallId.isEmpty) return false;
    if (eventCallId == null || eventCallId.isEmpty) return true;

    return eventCallId == activeCallId;
  }

  bool _canAccept(CallState state) {
    return _isIncomingRinging(state) &&
        state.backendStatus == BackendCallStatus.ringing &&
        !_isTerminal(state.backendStatus) &&
        !state.isBusy;
  }

  bool _isIncomingRinging(CallState state) {
    return state.uiPhase == UiCallPhase.incomingRinging &&
        state.direction?.trim().toLowerCase() == 'incoming' &&
        state.backendStatus == BackendCallStatus.ringing;
  }

  bool _canEndOrCancel(CallState state) {
    return state.uiPhase == UiCallPhase.outgoingStarting ||
        state.uiPhase == UiCallPhase.outgoingRinging ||
        state.uiPhase == UiCallPhase.joiningRoom ||
        state.uiPhase == UiCallPhase.inCall;
  }

  bool _isTerminal(BackendCallStatus? status) {
    return status == BackendCallStatus.ended ||
        status == BackendCallStatus.rejected ||
        status == BackendCallStatus.missed ||
        status == BackendCallStatus.cancelled ||
        status == BackendCallStatus.failed;
  }
}
