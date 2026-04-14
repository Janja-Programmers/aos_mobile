import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

class AppNavigation {
  static Future<void> goTo(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final item = AppNavConfig.items(context)[index];
    final auth = ref.read(authControllerProvider);

    if (item.requiresAuth && auth is! AuthAuthenticated) {
      await _showLoginRequiredSheet(context);
      return;
    }

    if (context.mounted) {
      context.goNamed(item.routeName);
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

          /// Close sheet
          onPrimary: () => Navigator.of(sheetContext).pop(),

          /// Navigate to login
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
