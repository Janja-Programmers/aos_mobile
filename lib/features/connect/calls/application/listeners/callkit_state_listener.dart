import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallKitStateListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallKitStateListener({super.key, required this.child});

  @override
  ConsumerState<CallKitStateListener> createState() =>
      _CallKitStateListenerState();
}

class _CallKitStateListenerState extends ConsumerState<CallKitStateListener> {
  ProviderSubscription<CallState>? _sub;

  @override
  void initState() {
    super.initState();

    _sub = ref.listenManual<CallState>(
      callManagerProvider,
      _handleCallStateChanged,
    );
  }

  Future<void> _handleCallStateChanged(
    CallState? previous,
    CallState next,
  ) async {
    final previousCall = previous?.activeCall;
    final activeCall = next.activeCall ?? previousCall;

    final callId = activeCall?.id;
    if (callId == null || callId.isEmpty) return;

    final previousPhase = previous?.uiPhase;
    final nextPhase = next.uiPhase;

    final previousCallId = previousCall?.id;

    final sameCall = previousCallId == callId;
    final samePhase = previousPhase == nextPhase;

    if (sameCall && samePhase) {
      return;
    }

    final callKit = ref.read(callKitServiceProvider);

    if (nextPhase == UiCallPhase.incomingRinging) {
      appLogger.i(
        '📞 CallKitStateListener: incomingRinging → showIncomingCall($callId)',
      );

      await callKit.showIncomingCall(
        callId: callId,
        callType: activeCall!.callType,
        caller: next.caller ?? activeCall.caller,
        roomName: activeCall.roomName,
      );

      return;
    }

    if (nextPhase == UiCallPhase.inCall) {
      appLogger.i(
        '📞 CallKitStateListener: inCall → setCallConnected($callId)',
      );

      await callKit.setCallConnected(callId);
      return;
    }

    if (_isTerminalPhase(nextPhase)) {
      appLogger.i(
        '📞 CallKitStateListener: terminal($nextPhase) → endCall($callId)',
      );

      await callKit.endCall(callId: callId);
      return;
    }

    if (nextPhase == UiCallPhase.idle && previousCallId != null) {
      final cameFromTerminal =
          previousPhase != null && _isTerminalPhase(previousPhase);

      if (cameFromTerminal) {
        return;
      }

      appLogger.i(
        '📞 CallKitStateListener: idle → end previous CallKit call($previousCallId)',
      );

      await callKit.endCall(callId: previousCallId);
      return;
    }
  }

  bool _isTerminalPhase(UiCallPhase phase) {
    return phase == UiCallPhase.finished ||
        phase == UiCallPhase.cancelled ||
        phase == UiCallPhase.error;
  }

  @override
  void dispose() {
    _sub?.close();
    _sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
