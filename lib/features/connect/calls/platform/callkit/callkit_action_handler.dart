import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';

/// Executes native CallKit actions against the backend-authoritative call state.
///
/// A `false` result means the action must remain pending because its backend
/// outcome could not be established yet (for example, temporary network loss).
/// Callers may retry later. A `true` result means the action is either applied
/// or no longer applicable because the backend has already advanced the call.
class CallKitActionHandler {
  final CallManager callManager;

  const CallKitActionHandler({required this.callManager});

  Future<bool> handlePendingAction({
    required PendingCallKitAction action,
    required String callId,
  }) {
    return switch (action) {
      PendingCallKitAction.accept => onAccept(callId: callId),
      PendingCallKitAction.decline => onDecline(callId: callId),
      PendingCallKitAction.ended => onEnded(callId: callId),
      PendingCallKitAction.timeout => onTimeout(callId: callId),
    };
  }

  Future<bool> onAccept({required String? callId}) async {
    final hydration = await _hydrateIfNeeded(callId);
    if (_isAuthoritativelyResolved(hydration)) return true;
    if (hydration != IncomingCallHydrationOutcome.hydrated) return false;

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Deferring CallKit accept: eventCallId=$callId '
        'activeCallId=$activeCallId',
      );
      return false;
    }

    if (_isStableTerminal(snapshot.backendStatus)) return true;

    await callManager.acceptIncomingCall(expectedCallId: callId);
    final status = callManager.currentState.backendStatus;
    return status == BackendCallStatus.ongoing || _isStableTerminal(status);
  }

  Future<bool> onDecline({required String? callId}) async {
    final hydration = await _hydrateIfNeeded(callId);
    if (_isAuthoritativelyResolved(hydration)) return true;
    if (hydration != IncomingCallHydrationOutcome.hydrated) return false;

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) {
      appLogger.w(
        '⚠️ Deferring CallKit decline: eventCallId=$callId '
        'activeCallId=$activeCallId',
      );
      return false;
    }

    if (_isStableTerminal(snapshot.backendStatus)) return true;

    await callManager.rejectIncomingCall(expectedCallId: callId);
    final status = callManager.currentState.backendStatus;

    // If another device already accepted the call, decline is no longer a
    // legal transition and the authoritative ongoing state wins.
    return status == BackendCallStatus.ongoing || _isStableTerminal(status);
  }

  Future<bool> onEnded({required String? callId}) async {
    final hydration = await _hydrateIfNeeded(callId);
    if (_isAuthoritativelyResolved(hydration)) return true;
    if (hydration != IncomingCallHydrationOutcome.hydrated) return false;

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) return false;
    if (_isStableTerminal(snapshot.backendStatus)) return true;

    if (snapshot.direction?.trim().toLowerCase() == 'incoming' &&
        snapshot.uiPhase != UiCallPhase.joiningRoom &&
        snapshot.uiPhase != UiCallPhase.inCall) {
      await callManager.rejectIncomingCall(expectedCallId: callId);
    } else if (_canEndOrCancel(snapshot)) {
      await callManager.endCurrentCall(expectedCallId: callId);
    } else {
      return false;
    }

    return _isStableTerminal(callManager.currentState.backendStatus);
  }

  Future<bool> onTimeout({required String? callId}) async {
    final hydration = await _hydrateIfNeeded(callId);
    if (_isAuthoritativelyResolved(hydration)) return true;
    if (hydration != IncomingCallHydrationOutcome.hydrated) return false;

    final snapshot = callManager.currentState;
    final activeCallId = snapshot.activeCall?.id;

    if (!_matchesActiveCall(callId, activeCallId)) return false;
    if (_isStableTerminal(snapshot.backendStatus)) return true;

    await callManager.callNotAnswered(expectedCallId: callId);
    final status = callManager.currentState.backendStatus;

    // An ongoing backend state means the native timeout was stale and must not
    // overwrite the accepted call as missed.
    return status == BackendCallStatus.ongoing || _isStableTerminal(status);
  }

  Future<IncomingCallHydrationOutcome> _hydrateIfNeeded(String? callId) async {
    final normalizedCallId = callId?.trim();
    if (normalizedCallId == null || normalizedCallId.isEmpty) {
      return IncomingCallHydrationOutcome.unavailable;
    }

    final snapshot = callManager.currentState;
    if (snapshot.activeCall?.id == normalizedCallId) {
      return IncomingCallHydrationOutcome.hydrated;
    }

    final outcome = await callManager.ensureIncomingCallHydrationOutcome(
      callId: normalizedCallId,
    );

    if (outcome == IncomingCallHydrationOutcome.hydrated) {
      appLogger.i(
        '📞 Hydrated CallManager from CallKit event: $normalizedCallId',
      );
    }

    return outcome;
  }

  bool _matchesActiveCall(String? eventCallId, String? activeCallId) {
    if (activeCallId == null || activeCallId.isEmpty) return false;
    if (eventCallId == null || eventCallId.isEmpty) return true;

    return eventCallId == activeCallId;
  }

  bool _canEndOrCancel(CallState state) {
    return state.uiPhase == UiCallPhase.outgoingStarting ||
        state.uiPhase == UiCallPhase.outgoingRinging ||
        state.uiPhase == UiCallPhase.joiningRoom ||
        state.uiPhase == UiCallPhase.inCall;
  }

  bool _isAuthoritativelyResolved(IncomingCallHydrationOutcome outcome) {
    return outcome == IncomingCallHydrationOutcome.terminal;
  }

  bool _isStableTerminal(BackendCallStatus? status) {
    return status == BackendCallStatus.ended ||
        status == BackendCallStatus.rejected ||
        status == BackendCallStatus.missed ||
        status == BackendCallStatus.cancelled;
  }
}
