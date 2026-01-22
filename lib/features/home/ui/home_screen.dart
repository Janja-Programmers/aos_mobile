import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/theme/app_theme.dart';

import 'package:aos_mobile/features/auth/providers/auth_controller.dart';

import 'package:aos_mobile/shared/widgets/app_bottom_nav.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('AOS Home'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Landing Page', style: AppTheme.h1(context)),
            const SizedBox(height: 10),
            Text(
              auth.isLoggedIn
                  ? 'Logged in as: ${auth.user?.email ?? ''}'
                  : 'You are not logged in.',
              style: AppTheme.bodyMuted(context),
            ),
            const SizedBox(height: 22),

            if (!auth.isLoggedIn) ...[
              AppTheme.primaryButton(
                text: 'Login',
                onPressed: () => context.push(AppRoutes.login),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text('Create account'),
              ),
            ] else ...[
              AppTheme.primaryButton(
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
