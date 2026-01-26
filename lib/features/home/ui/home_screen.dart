import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';

import 'package:aos_mobile/features/auth/providers/auth_controller.dart';

import 'package:aos_mobile/ui/components/app_bottom_nav.dart';
import 'package:aos_mobile/ui/components/app_text_styles.dart';
import 'package:aos_mobile/ui/components/buttons/primary_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('AOS Home'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Landing Page', style: context.h1),
            const SizedBox(height: 10),
            Text(
              auth.isLoggedIn
                  ? 'Logged in as: ${auth.user?.email ?? ''}'
                  : 'You are not logged in.',
              style: TextStyle(color: colors.muted),
            ),
            const SizedBox(height: 22),
            if (!auth.isLoggedIn) ...[
              PrimaryButton(
                text: 'Login',
                onPressed: () => context.push(AppRoutes.login),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.register),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onSurface,
                  side: BorderSide(color: colors.stroke),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ),
                child: const Text('Create account'),
              ),
            ] else ...[
              PrimaryButton(
                text: 'Logout',
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
