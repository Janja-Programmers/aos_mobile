import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/layout/app_dimensions.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/routing/app_nav_item.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/app_bottom_bar_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = AppNavConfig.items(context);

    return AppBottomBarSurface(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final item = items[index];
          Future<void> onTap() => AppNavigation.goTo(context, ref, index);

          if (index == 2) {
            return _PostButton(
              item: item,
              active: currentIndex == index,
              onTap: onTap,
            );
          }

          return _NavItem(
            item: item,
            active: currentIndex == index,
            onTap: onTap,
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? context.appColors.primary
        : context.appColors.textPrimary;

    return Expanded(
      child: GestureDetector(
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
                    ? context.appColors.primary.withValues(alpha: 0.1)
                    : context.appColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                active ? item.activeIcon : item.icon,
                size: AppDimensions.sizes.iconLg,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bottomNavLabel(selected: active),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  final AppNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _PostButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                boxShadow: AppDimensions.shadows.sellButton(colors.primary),
              ),
              child: Icon(item.icon, size: 24, color: colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bottomNavLabel(selected: active),
            ),
          ],
        ),
      ),
    );
  }
}
