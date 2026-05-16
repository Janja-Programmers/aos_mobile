import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/widgets/ringing/avator.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/ringing/incoming.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/ringing/outgoing.dart';

class RingingScreen extends ConsumerWidget {
  const RingingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);
    final colors = context.appColors;

    final isIncoming = state.uiPhase == UiCallPhase.incomingRinging;
    final name = _displayName(state);
    final initials = _initials(name);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // 🔹 Avatar
            Avatar(initials: initials),

            const SizedBox(height: 20),

            // 🔹 Name
            Text(
              name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // 🔹 Status text
            Text(
              isIncoming ? 'Incoming call...' : _outgoingText(state),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Spacer(),

            // 🔹 Actions
            if (isIncoming)
              IncomingActions(
                onAccept: manager.acceptIncomingCall,
                onReject: manager.rejectIncomingCall,
              )
            else
              OutgoingActions(onCancel: manager.endCurrentCall),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  String _outgoingText(CallState state) {
    switch (state.uiPhase) {
      case UiCallPhase.outgoingStarting:
        return 'Starting call...';
      case UiCallPhase.outgoingRinging:
        return 'Calling...';
      default:
        return '';
    }
  }

  String _displayName(CallState state) {
    if (state.uiPhase == UiCallPhase.incomingRinging) {
      return state.caller?.displayName ??
          state.caller?.userId ??
          'Incoming call';
    }

    return state.receiver?.displayName ??
        state.receiver?.userId ??
        'Calling...';
  }

  String _initials(String text) {
    final clean = text.trim();

    if (clean.isEmpty) return '?';

    final parts = clean
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
