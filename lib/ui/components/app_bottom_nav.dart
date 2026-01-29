import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,

          selectedItemColor: scheme.primary,
          unselectedItemColor: context.appColors.textMuted,

          selectedFontSize: 12,
          unselectedFontSize: 12,

          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),

          onTap: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.home);
                break;
              case 1:
                context.go(AppRoutes.categories);
                break;
              case 2:
                context.go(AppRoutes.home);
                break;
              case 3:
                context.go(AppRoutes.home);
                break;
              case 4:
                context.go(
                  auth.isLoggedIn ? AppRoutes.account : AppRoutes.login,
                );
                break;
            }
          },

          items: [
            _item(
              context,
              icon: Icons.home_outlined,
              label: 'Home',
              active: currentIndex == 0,
            ),
            _item(
              context,
              icon: Icons.grid_view_rounded,
              label: 'Categories',
              active: currentIndex == 1,
            ),

            /// CENTER SELL BUTTON
            BottomNavigationBarItem(
              label: 'Sell',
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.appColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),

            _item(
              context,
              icon: Icons.chat_bubble_outline,
              label: 'Messages',
              active: currentIndex == 3,
            ),
            _item(
              context,
              icon: Icons.person_outline,
              label: 'Account',
              active: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(
        icon,
        color: active
            ? context.appColors.primary
            : context.appColors.textPrimary,
      ),
    );
  }
}
