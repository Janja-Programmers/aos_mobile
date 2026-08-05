import 'dart:async';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';
import 'package:africaonlinestores/features/notifications/application/state/notification_state.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/presentation/utils/helpers.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/empty_view.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/error_view.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_action_sheet.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_tabs.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    // Riverpod 3 rejects provider mutations while the route is mounting.
    // Load only after the first frame, matching the Calls screen lifecycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      appLogger.i('🔔 NotificationsScreen → loadNotifications');
      unawaited(
        ref.read(notificationControllerProvider.notifier).loadNotifications(),
      );
    });
  }

  void _showNotificationBottomSheet({
    required BuildContext context,
    required NotificationItem notification,
    required NotificationNavigationHandler handler,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: NotificationActionSheet(
            notification: notification,
            onAction: () {
              Navigator.of(sheetContext).pop();
              unawaited(
                _handleNotificationAction(
                  notification: notification,
                  handler: handler,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleNotificationAction({
    required NotificationItem notification,
    required NotificationNavigationHandler handler,
  }) async {
    if (notification.type != NotificationType.missedCall) {
      final handled = handler.handleNotificationTap(notification);
      if (!handled) {
        appLogger.w(
          '🔔 Notification action has no supported destination '
          '(id=${notification.id}, type=${notification.type.value})',
        );
      }
      return;
    }

    // Persistent notification serialization exposes the caller's canonical
    // public account ID as actorId. Payload caller/user fields may still carry
    // the backend User ID, so use them only as compatibility fallbacks.
    final callerUserId = _clean(
      notification.actorId ??
          notification.payload.otherUser ??
          notification.payload.userId,
    );

    if (callerUserId == null) {
      appLogger.e(
        '📞 Missed-call notification has no canonical caller account ID '
        '(notificationId=${notification.id}, '
        'callId=${notification.payload.callId ?? 'none'})',
      );
      _showActionFailure('Caller information is unavailable.');
      return;
    }

    final callerDisplayName =
        _clean(
          notification.payload.actorName ??
              notification.payload.otherUserName ??
              notification.actorName,
        ) ??
        callerUserId;
    final callerAvatar = _clean(
      notification.payload.actorAvatar ?? notification.actorAvatar,
    );

    appLogger.i(
      '📞 Missed-call notification callback tapped '
      '(notificationId=${notification.id}, '
      'callId=${notification.payload.callId ?? 'none'}, caller=$callerUserId)',
    );

    try {
      final started = await ref
          .read(missedCallCallbackServiceProvider)
          .callBack(
            callerUserId: callerUserId,
            callerDisplayName: callerDisplayName,
            callerAvatarUrl: callerAvatar,
            originalCallId: notification.payload.callId,
          );

      if (!started) {
        _showActionFailure('Could not start the call. Please try again.');
      }
    } catch (error, stackTrace) {
      appLogger.e(
        '📞 Missed-call callback failed unexpectedly '
        '(notificationId=${notification.id})',
        error: error,
        stackTrace: stackTrace,
      );
      _showActionFailure('Could not start the call. Please try again.');
    }
  }

  void _showActionFailure(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
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
              onPressed: () => unawaited(controller.markAllAsRead()),
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
    required NotificationState state,
    required List<NotificationItem> items,
    required NotificationController controller,
    required NotificationNavigationHandler handler,
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
    final originalIndexes = <String, int>{
      for (var i = 0; i < state.items.length; i++) state.items[i].id: i,
    };
    final rows = <Object>[];

    for (final entry in grouped.entries) {
      rows.add(entry.key);
      for (final item in entry.value) {
        rows.add(item);
      }
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView.separated(
        scrollCacheExtent: const ScrollCacheExtent.pixels(600),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: rows.length,
        separatorBuilder: (_, _) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final row = rows[index];

          if (row is String) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                row,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          }

          final n = row as NotificationItem;
          final originalIndex = originalIndexes[n.id] ?? 0;

          return RepaintBoundary(
            child: NotificationTile(
              notification: n,
              onTap: () {
                unawaited(controller.markNotificationRead(n.id));

                _showNotificationBottomSheet(
                  context: context,
                  notification: n,
                  handler: handler,
                );
              },
              onDelete: () {
                unawaited(controller.deleteNotification(n.id));

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Notification deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        controller.restoreNotification(n, originalIndex);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
