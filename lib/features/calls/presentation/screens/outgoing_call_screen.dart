import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/calls/application/providers/call_providers.dart';
import 'package:go_router/go_router.dart';

class OutgoingCallScreen extends ConsumerWidget {
  const OutgoingCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);

    final receiver = callState.receiver;

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              CircleAvatar(
                radius: 50,
                backgroundImage: receiver?.avatarUrl != null
                    ? NetworkImage(receiver!.avatarUrl!)
                    : null,
                child: receiver?.avatarUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),

              const SizedBox(height: 16),

              Text(
                receiver?.displayName ?? 'Calling...',
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),

              const SizedBox(height: 8),

              const Text('Ringing...', style: TextStyle(color: Colors.grey)),

              const Spacer(),

              FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () async {
                  await manager.endCurrentCall();

                  if (context.mounted) {
                    context.pop();
                  }
                },
                child: const Icon(Icons.call_end),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
