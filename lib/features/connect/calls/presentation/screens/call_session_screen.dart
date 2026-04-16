import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/screens/active_call_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/ringing_screen.dart';

class CallSessionScreen extends ConsumerStatefulWidget {
  final String user;
  final String displayName;
  final bool isVideo;

  const CallSessionScreen({
    super.key,
    required this.user,
    required this.displayName,
    required this.isVideo,
  });

  @override
  ConsumerState<CallSessionScreen> createState() => _CallSessionScreenState();
}

class _CallSessionScreenState extends ConsumerState<CallSessionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callManagerProvider);

    return _buildByPhase(state.uiPhase);
  }

  // -------------------------
  // UI SWITCHER (CORE LOGIC)
  // -------------------------
  Widget _buildByPhase(UiCallPhase phase) {
    switch (phase) {
      // 📞 RINGING STATES
      case UiCallPhase.incomingRinging:
      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
        return const RingingScreen();

      // 🔄 CONNECTING || 🎥 ACTIVE CALL
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
        return const ActiveCallScreen();

      // ❌ TRANSITION STATE ONLY (VERY SHORT)
      case UiCallPhase.finished:
        return const SizedBox.shrink();

      // ⚠️ SHOULD NEVER STAY HERE
      case UiCallPhase.idle:
      default:
        return const SizedBox.shrink();
    }
  }
}
