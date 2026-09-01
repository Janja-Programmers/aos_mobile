import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_badge_provider.dart';
import 'package:africaonlinestores/features/notifications/navigation/notification_routes.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/feed_search_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_l10n.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: AppSearchBar(
              controller: _searchController,
              hintText: context.l10n.feedSearchHint,
              margin: EdgeInsets.zero,
              height: 46,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 10),
          NotificationBadge(
            count: unreadCount,
            child: _FeedHeaderIconButton(
              icon: Icons.notifications_none_rounded,
              semanticsLabel: context.l10n.feedNotifications,
              onTap: _openNotifications,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedHeaderIconButton extends StatelessWidget {
  const _FeedHeaderIconButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: colors.surface,
        shape: CircleBorder(side: BorderSide(color: colors.border)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 21, color: colors.textPrimary),
          ),
        ),
      ),
    );
  }
}
