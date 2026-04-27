import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/video_call_ringing_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/video_call_screen.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/screens/active_call_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/ringing_screen.dart';

class CallSessionScreen extends ConsumerStatefulWidget {
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
  ConsumerState<CallSessionScreen> createState() => _CallSessionScreenState();
}

class _CallSessionScreenState extends ConsumerState<CallSessionScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callManagerProvider);

    return _buildByPhase(state);
  }

  // -------------------------
  Widget _buildByPhase(CallState state) {
    final phase = state.uiPhase;
    final isVideo = state.callMediaMode == CallMediaMode.video;

    switch (phase) {
      // 📞 RINGING
      case UiCallPhase.incomingRinging:
      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
        return isVideo ? const VideoRingingScreen() : const RingingScreen();

      // 🎥 / 🔊 ACTIVE
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
      case UiCallPhase.cancelled:
        return isVideo ? const VideoCallScreen() : const ActiveCallScreen();

      // ❌ EXIT
      case UiCallPhase.finished:
      case UiCallPhase.idle:
      default:
        return const SizedBox.shrink();
    }
  }
}
