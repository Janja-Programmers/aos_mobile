import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';

/// Home AppBar for Ads List (Home).
/// - Title row + favorites/notifications actions
/// - Location pill (tap to open bottom sheet)
///
/// NOTE: Search bar is intentionally NOT included here.
/// Put search directly under the AppBar in the page BODY.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.title = 'Africa Online Stores',
    required this.locationLabel,
    this.onTapLocation,
    this.onTapFavorites,
    this.onTapNotifications,
    this.height = 72,
  });

  final String title;
  final String locationLabel;

  final VoidCallback? onTapLocation;
  final VoidCallback? onTapFavorites;
  final VoidCallback? onTapNotifications;

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      toolbarHeight: height,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                _CircleIconButton(
                  icon: Icons.favorite_border,
                  onTap: onTapFavorites,
                ),
                const SizedBox(width: 10),
                _CircleIconButton(
                  icon: Icons.notifications_none,
                  onTap: onTapNotifications,
                ),
              ],
            ),

            GestureDetector(
              onTap: onTapLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    locationLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, size: 20, color: colors.textPrimary),
      ),
    );
  }
}
