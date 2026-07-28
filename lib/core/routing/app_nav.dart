import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/routing/app_nav_item.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  static Future<void> goTo(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final items = AppNavConfig.items(context);
    if (index < 0 || index >= items.length) return;

    final item = items[index];
    final auth = ref.read(authControllerProvider);

    if (item.requiresAuth && auth is! AuthAuthenticated) {
      await _showLoginRequiredSheet(context);
      return;
    }

    if (!context.mounted) return;

    final location = GoRouterState.of(context).uri.toString();
    if (item.isDestination(location)) return;

    switch (item.behavior) {
      case AppNavBehavior.replace:
        context.goNamed(item.routeName);
        return;
      case AppNavBehavior.push:
        await context.pushNamed(item.routeName);
        return;
    }
  }

  static Future<void> requireAuth(
    BuildContext context,
    WidgetRef ref, {
    required VoidCallback onAuthenticated,
  }) async {
    final auth = ref.read(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      await _showLoginRequiredSheet(context);
      return;
    }

    if (context.mounted) {
      onAuthenticated();
    }
  }

  static Future<void> _showLoginRequiredSheet(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      builder: (sheetContext) {
        return AppConfirmSheet(
          icon: Icons.lock_outlined,
          iconBg: scheme.primary,
          title: 'Login required',
          message: 'Please login to continue',
          primaryText: 'Cancel',
          secondaryText: 'Log in',
          onPrimary: () => Navigator.of(sheetContext).pop(),
          onSecondary: () {
            Navigator.of(sheetContext).pop();

            if (context.mounted) {
              context.goNamed(AppRoutes.nLogin);
            }
          },
        );
      },
    );
  }
}
