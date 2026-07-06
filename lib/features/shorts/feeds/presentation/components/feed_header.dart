import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_badge_provider.dart';
import 'package:africaonlinestores/features/notifications/navigation/notification_routes.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/feed_search_controller.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedHeader extends ConsumerStatefulWidget {
  const FeedHeader({super.key});

  @override
  ConsumerState<FeedHeader> createState() => _FeedHeaderState();
}

class _FeedHeaderState extends ConsumerState<FeedHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(feedSearchControllerProvider).onQueryChanged(ref, value);
  }

  void _openNotifications() {
    NotificationsNavigation.toNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(notificationUnreadCountProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search shorts...',
              margin: EdgeInsets.zero,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 10),
          NotificationBadge(
            count: unreadCount,
            child: _FeedHeaderIconButton(
              icon: Icons.notifications_none,
              onTap: _openNotifications,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedHeaderIconButton extends StatelessWidget {
  const _FeedHeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final surface = colors.surface;
    final border = colors.border;
    final primary = colors.primary;

    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, size: 22, color: primary),
        ),
      ),
    );
  }
}
