import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/active_call_layout.dart';

class ActiveCallScreen extends ConsumerWidget {
  const ActiveCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);
    final colors = context.appColors;

    final participant = _displayName(callState);
    final subtitle = _subtitle(callState);
    final initials = _initials(participant);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: ActiveCallLayout(
          callState: callState,
          manager: manager,
          participant: participant,
          subtitle: subtitle,
          initials: initials,
        ),
      ),
    );
  }

  static String _displayName(CallState callState) {
    if (callState.direction == 'incoming') {
      return callState.caller?.displayName ??
          callState.caller?.userId ??
          'Incoming call';
    }

    return callState.receiver?.displayName ??
        callState.receiver?.userId ??
        callState.activeCall?.receiver?.displayName ??
        callState.activeCall?.receiver?.userId ??
        callState.activeCall?.caller?.displayName ??
        callState.activeCall?.caller?.userId ??
        'Calling...';
  }

  static String _subtitle(CallState callState) {
    switch (callState.uiPhase) {
      case UiCallPhase.joiningRoom:
        return 'Connecting...';

      case UiCallPhase.inCall:
        return 'In call';

      case UiCallPhase.finished:
        return 'Call ended';

      case UiCallPhase.cancelled:
        return 'Call cancelled';

      default:
        return '';
    }
  }

  static String _initials(String text) {
    final parts = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
