import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/ringing/avator.dart';

class ClosingCallView extends StatelessWidget {
  final CallState state;

  const ClosingCallView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final name = _displayName(state);
    final initials = _initials(name);
    final status = _statusText(state);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              Avatar(initials: initials),

              const SizedBox(height: 20),

              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(status, style: context.pMuted, textAlign: TextAlign.center),

              const Spacer(),

              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),

              const SizedBox(height: 14),

              Text('Returning to calls...', style: context.pMuted),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(CallState state) {
    switch (state.uiPhase) {
      case UiCallPhase.finished:
        return 'Call ended';
      case UiCallPhase.cancelled:
        return 'Call cancelled';
      case UiCallPhase.error:
        return 'Call failed';
      case UiCallPhase.idle:
        return 'Ending call...';
      case UiCallPhase.incomingRinging:
        return 'Opening incoming call...';
      default:
        return 'Ending call...';
    }
  }

  String _displayName(CallState state) {
    return state.caller?.displayName ??
        state.receiver?.displayName ??
        state.caller?.userId ??
        state.receiver?.userId ??
        'AOS Call';
  }

  String _initials(String text) {
    final cleaned = text.trim();

    if (cleaned.isEmpty) return 'A';

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'A';

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
