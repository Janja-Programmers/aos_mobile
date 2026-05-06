import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

class CallAudioFeedbackListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallAudioFeedbackListener({super.key, required this.child});

  @override
  ConsumerState<CallAudioFeedbackListener> createState() =>
      _CallAudioFeedbackListenerState();
}

class _CallAudioFeedbackListenerState
    extends ConsumerState<CallAudioFeedbackListener> {
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
    final previousPhase = previous?.uiPhase;
    final nextPhase = next.uiPhase;

    final previousDirection = previous?.direction;
    final nextDirection = next.direction;

    final phaseChanged = previousPhase != nextPhase;
    final directionChanged = previousDirection != nextDirection;

    if (!phaseChanged && !directionChanged) return;

    final audio = ref.read(callAudioFeedbackServiceProvider);

    if (_shouldPlayRingback(next)) {
      await audio.playRingback();
      return;
    }

    if (_shouldStopRingback(next)) {
      await audio.stopRingback();
      return;
    }
  }

  bool _shouldPlayRingback(CallState state) {
    final isOutgoing = state.direction == 'outgoing';

    return isOutgoing &&
        (state.uiPhase == UiCallPhase.outgoingStarting ||
            state.uiPhase == UiCallPhase.outgoingRinging);
  }

  bool _shouldStopRingback(CallState state) {
    return state.uiPhase == UiCallPhase.incomingRinging ||
        state.uiPhase == UiCallPhase.joiningRoom ||
        state.uiPhase == UiCallPhase.inCall ||
        state.uiPhase == UiCallPhase.finished ||
        state.uiPhase == UiCallPhase.cancelled ||
        state.uiPhase == UiCallPhase.error ||
        state.uiPhase == UiCallPhase.idle;
  }

  @override
  void dispose() {
    _sub?.close();
    _sub = null;

    ref.read(callAudioFeedbackServiceProvider).stopRingback();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
