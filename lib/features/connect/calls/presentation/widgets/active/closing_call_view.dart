import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_participant_resolver.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/ringing/avator.dart';

class ClosingCallView extends ConsumerWidget {
  final CallState state;

  const ClosingCallView({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final currentUserId = ref.watch(currentUserProvider);

    final participant = CallParticipantResolver.otherParticipant(
      state,
      currentUserId: currentUserId,
      fallbackName: 'AOS Call',
    );
    final status = _statusText(state);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              Avatar(initials: participant.initials),

              const SizedBox(height: 20),

              Text(
                participant.displayName,
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
    switch (state.backendStatus) {
      case BackendCallStatus.ended:
        return 'Call ended';
      case BackendCallStatus.rejected:
        return 'Call declined';
      case BackendCallStatus.missed:
        return 'No answer';
      case BackendCallStatus.cancelled:
        return 'Call cancelled';
      case BackendCallStatus.failed:
        return 'Call failed';
      case BackendCallStatus.initiated:
      case BackendCallStatus.ringing:
      case BackendCallStatus.ongoing:
        return 'Ending call...';
      case null:
        break;
    }

    switch (state.uiPhase) {
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
}
