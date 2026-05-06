import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/screens/active_call_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/closing_call_view.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/ringing_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/video_call_ringing_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/video_call_screen.dart';

class CallSessionScreen extends ConsumerWidget {
  final String? user;
  final String? displayName;
  final bool? isVideo;

  const CallSessionScreen({
    super.key,
    this.user,
    this.displayName,
    this.isVideo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);
    return _buildByPhase(state);
  }

  Widget _buildByPhase(CallState state) {
    final isVideo = state.callMediaMode == CallMediaMode.video;

    switch (state.uiPhase) {
      /// Incoming ringing is handled by native CallKit.
      case UiCallPhase.incomingRinging:
        return ClosingCallView(state: state);

      /// Outgoing calls still use AOS ringing UI.
      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
        return isVideo ? const VideoRingingScreen() : const RingingScreen();

      /// Accepted / active call.
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
        return isVideo ? const VideoCallScreen() : const ActiveCallScreen();

      /// Terminal / no active session.
      case UiCallPhase.finished:
      case UiCallPhase.cancelled:
      case UiCallPhase.error:
      case UiCallPhase.idle:
        return ClosingCallView(state: state);
    }
  }
}
