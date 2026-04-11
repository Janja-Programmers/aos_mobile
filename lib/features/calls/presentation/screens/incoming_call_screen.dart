import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/calls/presentation/widgets/incoming_call/incoming_call_view.dart';

class IncomingCallScreen extends ConsumerWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);

    final caller = callState.caller;

    return IncomingCallView(
      name: caller?.displayName ?? 'Unknown',
      avatarUrl: caller?.avatarUrl,
      onAccept: manager.acceptIncomingCall,
      onReject: manager.rejectIncomingCall,
    );
  }
}
