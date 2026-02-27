import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/routing/app_routes.dart';

import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';

class AppNavigation {
  static Future<void> goTo(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final item = AppNavConfig.items[index];
    final auth = ref.read(authControllerProvider);

    Future<void> showLoginRequiredSheet(
      BuildContext context,
      WidgetRef ref,
    ) async {
      final scheme = Theme.of(context).colorScheme;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return AppConfirmSheet(
            icon: Icons.lock_outlined,
            iconBg: scheme.primary,
            title: 'Login required',
            message: 'Please login to access selling',
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

    if (item.requiresAuth && !auth.isLoggedIn) {
      await showLoginRequiredSheet(context, ref);
      return;
    }

    context.goNamed(item.routeName);
  }
}
