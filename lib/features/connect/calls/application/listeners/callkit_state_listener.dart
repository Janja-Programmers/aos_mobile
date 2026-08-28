import 'dart:async';

import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
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
  ProviderSubscription<CallState>? _callSub;
  ProviderSubscription<AppLifecycleSnapshot>? _lifecycleSub;

  @override
  void initState() {
    super.initState();

    _callSub = ref.listenManual<CallState>(
      callManagerProvider,
      _handleCallStateChanged,
    );
    _lifecycleSub = ref.listenManual<AppLifecycleSnapshot>(
      appLifecycleControllerProvider,
      _handleLifecycleChanged,
    );
  }

  void _handleLifecycleChanged(
    AppLifecycleSnapshot? previous,
    AppLifecycleSnapshot next,
  ) {
    final becameVisible = !(previous?.isVisible ?? false) && next.isVisible;
    if (!becameVisible) return;
    if (ref.read(authControllerProvider) is! AuthAuthenticated) return;

    // A background/terminated Android action is persisted by the plugin's
    // background callback. Reconcile it whenever the authenticated app becomes
    // visible, not only on process startup.
    unawaited(ref.read(callKitRecoveryServiceProvider).recover());
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
    if (sameCall && samePhase) return;

    final callKit = ref.read(callKitServiceProvider);

    if (nextPhase == UiCallPhase.incomingRinging) {
      appLogger.i(
        '📞 CallKitStateListener: incomingRinging → showIncomingCall($callId)',
      );

      // On Android this notification remains the ringtone/background action
      // owner even when a visible app also renders the Flutter ringing screen.
      // On iOS it remains the native CallKit incoming-call surface.
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
      if (cameFromTerminal) return;

      appLogger.i(
        '📞 CallKitStateListener: idle → end previous CallKit call($previousCallId)',
      );
      await callKit.endCall(callId: previousCallId);
    }
  }

  bool _isTerminalPhase(UiCallPhase phase) {
    return phase == UiCallPhase.finished ||
        phase == UiCallPhase.cancelled ||
        phase == UiCallPhase.error;
  }

  @override
  void dispose() {
    _callSub?.close();
    _callSub = null;
    _lifecycleSub?.close();
    _lifecycleSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
