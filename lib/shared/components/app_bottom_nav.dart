import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/layout/app_dimensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        margin: AppDimensions.spacing.bottomNavMargin,
        padding: AppDimensions.spacing.bottomNavPadding,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppDimensions.radii.bottomNav,
          boxShadow: AppDimensions.shadows.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              active: currentIndex == 0,
              onTap: () => AppNavigation.goTo(context, ref, 0),
            ),
            _NavItem(
              label: 'Categories',
              icon: Icons.grid_view_outlined,
              activeIcon: Icons.grid_view_rounded,
              active: currentIndex == 1,
              onTap: () => AppNavigation.goTo(context, ref, 1),
            ),

            _SellButton(onTap: () => AppNavigation.goTo(context, ref, 2)),

            _NavItem(
              label: 'Feeds',
              icon: Icons.forum_outlined,
              activeIcon: Icons.forum_outlined,
              active: currentIndex == 3,
              onTap: () => AppNavigation.goTo(context, ref, 3),
            ),
            _NavItem(
              label: 'Account',
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              active: currentIndex == 4,
              onTap: () => AppNavigation.goTo(context, ref, 4),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? context.appColors.primary
        : context.appColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: active
                  ? context.appColors.primary.withOpacity(0.1)
                  : context.appColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              active ? activeIcon : icon,
              size: AppDimensions.sizes.iconLg,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.bottomNavLabel(selected: active)),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SellButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SellButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.appColors.primary,
              shape: BoxShape.circle,
              boxShadow: AppDimensions.shadows.sellButton(
                context.appColors.primary,
              ),
            ),
            child: Icon(Icons.add, size: 24, color: colors.white),
          ),
        ],
      ),
    );
  }
}
