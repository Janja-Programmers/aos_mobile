import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/ui/components/app_confirm_sheet.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  Future<void> _showLoginRequiredSheet(
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: context.appColors.surfaceBright,
            elevation: 0,
            selectedItemColor: scheme.primary,
            unselectedItemColor: context.appColors.textMuted,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),

            // ✅ make onTap async because we await the sheet
            onTap: (index) async {
              switch (index) {
                case 0:
                  context.goNamed(AppRoutes.nHome);
                  break;

                case 1:
                  context.goNamed(AppRoutes.nCategories);
                  break;

                case 2:
                  if (user == null) {
                    await _showLoginRequiredSheet(context, ref);
                  } else {
                    context.goNamed(AppRoutes.nMyAds);
                  }
                  break;

                case 3:
                  context.goNamed(AppRoutes.nHome);
                  break;

                case 4:
                  context.goNamed(AppRoutes.nAccount);
                  break;
              }
            },

            items: [
              _item(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                active: currentIndex == 0,
              ),
              _item(
                context,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Categories',
                active: currentIndex == 1,
              ),
              BottomNavigationBarItem(
                label: 'Sell',
                icon: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: context.appColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: context.appColors.border,
                    size: 20,
                  ),
                ),
              ),
              _item(
                context,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Messages',
                active: currentIndex == 3,
              ),
              _item(
                context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Account',
                active: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _item(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool active,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(
        active ? activeIcon : icon,
        color: active
            ? context.appColors.primary
            : context.appColors.textPrimary,
      ),
    );
  }
}
