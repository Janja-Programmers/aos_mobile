import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

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
              await AppNavigation.goTo(context, ref, index);
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
                label: 'Selling',
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
