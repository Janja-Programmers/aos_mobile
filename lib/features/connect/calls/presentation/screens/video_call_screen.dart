import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_participant_resolver.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/session/video_call_view.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoCallScreen extends ConsumerWidget {
  final bool showActiveControls;

  const VideoCallScreen({super.key, this.showActiveControls = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);
    final currentUserId = ref.watch(currentUserProvider);

    final participant = CallParticipantResolver.otherParticipant(
      state,
      currentUserId: currentUserId,
      fallbackName: state.direction == 'incoming'
          ? context.l10n.chat_incoming_video_call
          : context.l10n.chat_video_call,
    );

    return VideoCallView(
      callState: state,
      manager: manager,
      participant: participant,
      showActiveControls: showActiveControls,
    );
  }
}
