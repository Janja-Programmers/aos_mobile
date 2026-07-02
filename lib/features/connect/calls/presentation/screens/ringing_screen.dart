import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_participant_resolver.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/session/audio_call_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RingingScreen extends ConsumerWidget {
  const RingingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);
    final currentUserId = ref.watch(currentUserProvider);

    final isIncoming = state.uiPhase == UiCallPhase.incomingRinging;
    final participant = CallParticipantResolver.otherParticipant(
      state,
      currentUserId: currentUserId,
      fallbackName: isIncoming ? 'Incoming call' : 'Calling...',
    );

    return AudioCallView(
      callState: state,
      manager: manager,
      participant: participant,
      showIncomingActions: isIncoming,
    );
  }
}
