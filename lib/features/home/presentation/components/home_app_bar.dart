import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_badge_provider.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_badge.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.title = 'Africa Online Stores',
    required this.locationLabel,
    this.onTapLocation,
    this.onTapConnect,
    this.onTapNotifications,
    this.search,
    this.toolbarHeight = 72,
    this.searchPadding = const EdgeInsets.all(12),
  });

  final String title;
  final String locationLabel;
  final VoidCallback? onTapLocation;
  final VoidCallback? onTapConnect;
  final VoidCallback? onTapNotifications;
  final Widget? search;

  /// Main AppBar height (title + actions + location row).
  final double toolbarHeight;

  /// Padding applied around the injected [search] widget.
  ///
  /// Keeping this in the AppBar makes the layout consistent across screens.
  final EdgeInsets searchPadding;

  // AppSearchBar is height 60 by design.
  static const double _searchHeight = 54;

  @override
  Size get preferredSize {
    final bottom = search == null
        ? 0.0
        : (_searchHeight + searchPadding.vertical);
    return Size.fromHeight(toolbarHeight + bottom);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final unreadCount = ref.watch(notificationUnreadCountProvider);
    final chatUnreadCount = ref.watch(chatUnreadCountProvider);

    return AppBar(
      toolbarHeight: toolbarHeight,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      bottom: search == null
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(
                _searchHeight + searchPadding.vertical,
              ),
              child: Padding(padding: searchPadding, child: search!),
            ),
      titleSpacing: 16,
      title: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Africa',
                        style: TextStyle(color: colors.primary),
                      ),
                      TextSpan(
                        text: ' Online ',
                        style: TextStyle(color: colors.textPrimary),
                      ),
                      TextSpan(
                        text: 'Stores',
                        style: TextStyle(color: colors.success),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                NotificationBadge(
                  count: chatUnreadCount,
                  child: _CircleIconButton(
                    icon: Icons.contact_phone_outlined,
                    onTap: onTapConnect,
                  ),
                ),
                const SizedBox(width: 10),

                NotificationBadge(
                  count: unreadCount,
                  child: _CircleIconButton(
                    icon: Icons.notifications_none,
                    onTap: onTapNotifications,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
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
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? colors.textMuted : colors.primary,
        ),
      ),
    );
  }
}
