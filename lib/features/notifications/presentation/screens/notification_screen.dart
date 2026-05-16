import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/presentation/utils/helpers.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/empty_view.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/error_view.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_tabs.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      appLogger.i('🔔 NotificationsScreen → loadNotifications');
      ref.read(notificationControllerProvider.notifier).loadNotifications();
    });
  }

  void _showNotificationBottomSheet({
    required BuildContext context,
    required NotificationItem notification,
    required dynamic controller,
    required dynamic handler,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          top: false,
          child: NotificationActionSheet(
            notification: notification,
            onAction: () {
              Navigator.pop(context);
              handler.handleNotificationTap(notification);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);
    final handler = ref.read(notificationNavigationHandlerProvider);
    final colors = context.appColors;

    final filteredItems = filterNotifications(state.items, _selectedTab);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: controller.markAllAsRead,
              child: const Text('Read all'),
            ),
        ],
      ),

      body: Column(
        children: [
          // 🔹 Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: NotificationTabs(
              selected: _selectedTab,
              onChanged: (tab) {
                setState(() => _selectedTab = tab);
              },
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 Content
          Expanded(
            child: _buildBody(
              state: state,
              items: filteredItems,
              controller: controller,
              handler: handler,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BODY
  // =====================================================
  Widget _buildBody({
    required dynamic state,
    required List<NotificationItem> items,
    required dynamic controller,
    required dynamic handler,
  }) {
    // 🔄 Loading
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // ❌ Error
    if (state.errorMessage != null && state.items.isEmpty) {
      return NotofcationErrorView(
        message: state.errorMessage!,
        onRetry: controller.loadNotifications,
      );
    }

    // 📭 Empty
    if (items.isEmpty) {
      return const NotificationEmptyView();
    }

    // ✅ Data
    final grouped = groupByDate(items);

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              // Items
              ...entry.value.asMap().entries.map((itemEntry) {
                final index = itemEntry.key;
                final n = itemEntry.value;

                return NotificationTile(
                  notification: n,
                  onTap: () {
                    controller.markNotificationRead(n.id);

                    _showNotificationBottomSheet(
                      context: context,
                      notification: n,
                      controller: controller,
                      handler: handler,
                    );
                  },
                  onDelete: () {
                    controller.deleteNotification(n.id);

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notification deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            controller.restoreNotification(n, index);
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}
