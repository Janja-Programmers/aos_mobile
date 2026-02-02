import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';

import 'package:africaonlinestores/ui/components/app_bottom_nav.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

class AdListScreen extends ConsumerWidget {
  const AdListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('AOS Ad List'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ad List Page', style: context.h1),
            const SizedBox(height: 18),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createAd),
        icon: const Icon(Icons.add),
        label: const Text('Post Ad'),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
