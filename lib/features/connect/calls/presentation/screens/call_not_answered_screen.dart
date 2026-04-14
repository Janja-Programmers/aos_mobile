import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/call_views/reject_call_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CallNotAnsweredScreen extends ConsumerWidget {
  const CallNotAnsweredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);

    final caller = state.caller;

    return CallRejectedView(
      name: caller?.displayName ?? 'Unknown',
      avatarUrl: caller?.avatarUrl,
      onClose: () {
        context.goNamed(AppRoutes.nHome);
      },
    );
  }
}
