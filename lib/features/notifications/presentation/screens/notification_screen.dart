import 'dart:async';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_missed_call_action_coordinator.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';
import 'package:africaonlinestores/features/notifications/application/state/notification_state.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/presentation/utils/helpers.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/empty_view.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/error_view.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_action_sheet.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_tabs.dart';
import 'package:africaonlinestores/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(notificationControllerProvider.notifier).loadNotifications(),
      );
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 360) {
      unawaited(ref.read(notificationControllerProvider.notifier).loadMore());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NotificationState state = ref.watch(notificationControllerProvider);
    final NotificationController controller = ref.read(
      notificationControllerProvider.notifier,
    );
    final NotificationNavigationHandler handler = ref.read(
      notificationNavigationHandlerProvider,
    );
    final colors = context.appColors;

    ref.listen<String?>(
      notificationControllerProvider.select(
        (NotificationState value) => value.errorMessage,
      ),
      (String? previous, String? next) {
        if (!mounted ||
            next == null ||
            next == previous ||
            state.items.isEmpty) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(next)));
      },
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.chat_notifications),
        actions: <Widget>[
          PopupMenuButton<_NotificationMenuAction>(
            tooltip: context.l10n.chat_more_options,
            onSelected: (_NotificationMenuAction action) {
              unawaited(_handleMenuAction(action, state, controller));
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_NotificationMenuAction>>[
                  PopupMenuItem<_NotificationMenuAction>(
                    value: _NotificationMenuAction.markAllRead,
                    enabled: state.unreadCount > 0,
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.done_all_rounded),
                        const SizedBox(width: 12),
                        Text(context.l10n.chat_mark_all_read),
                      ],
                    ),
                  ),
                  PopupMenuItem<_NotificationMenuAction>(
                    value: _NotificationMenuAction.clear,
                    enabled: state.hasLoaded,
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.clear_all_rounded),
                        const SizedBox(width: 12),
                        Text(context.l10n.chat_clear),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: NotificationTabs(
                selected: state.category,
                onChanged: (NotificationCategory category) {
                  unawaited(controller.selectCategory(category));
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildBody(
                state: state,
                controller: controller,
                handler: handler,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(
    _NotificationMenuAction action,
    NotificationState state,
    NotificationController controller,
  ) async {
    switch (action) {
      case _NotificationMenuAction.markAllRead:
        await controller.markAllAsRead();
        return;
      case _NotificationMenuAction.clear:
        final bool confirmed = await _confirmClear(state.category);
        if (confirmed && mounted) await controller.clearCurrentCategory();
        return;
    }
  }

  Future<bool> _confirmClear(NotificationCategory category) async {
    final String label = NotificationTabs.label(category);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(context.l10n.chat_clear),
              content: Text('Clear all $label notifications?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.chat_cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(context.l10n.chat_clear),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildBody({
    required NotificationState state,
    required NotificationController controller,
    required NotificationNavigationHandler handler,
  }) {
    if (state.isLoading && !state.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && !state.hasLoaded) {
      return NotofcationErrorView(
        message: state.errorMessage!,
        onRetry: controller.loadNotifications,
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshNotifications,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(height: 120),
            NotificationEmptyView(),
          ],
        ),
      );
    }

    final Map<String, List<NotificationItem>> grouped = groupByDate(
      state.items,
    );
    final List<Object> rows = <Object>[];
    for (final MapEntry<String, List<NotificationItem>> entry
        in grouped.entries) {
      rows
        ..add(entry.key)
        ..addAll(entry.value);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: rows.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 2),
        itemBuilder: (BuildContext context, int index) {
          if (index == rows.length) {
            if (state.isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state.hasMore && state.errorMessage != null) {
              return Center(
                child: TextButton(
                  onPressed: () => unawaited(controller.loadMore()),
                  child: Text(context.l10n.common_try_again),
                ),
              );
            }
            return const SizedBox(height: 1);
          }

          final Object row = rows[index];
          if (row is String) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                row,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          }

          final NotificationItem notification = row as NotificationItem;
          return RepaintBoundary(
            child: NotificationTile(
              notification: notification,
              onTap: () {
                unawaited(controller.markNotificationRead(notification.id));
                _showNotificationBottomSheet(notification, handler);
              },
              onLongPress: () => _showDeleteSheet(notification, controller),
              onDelete: () {
                unawaited(controller.deleteNotification(notification.id));
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteSheet(
    NotificationItem notification,
    NotificationController controller,
  ) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext sheetContext) {
          return SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(
                MaterialLocalizations.of(context).deleteButtonTooltip,
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(controller.deleteNotification(notification.id));
              },
            ),
          );
        },
      ),
    );
  }

  void _showNotificationBottomSheet(
    NotificationItem notification,
    NotificationNavigationHandler handler,
  ) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext sheetContext) {
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
      ),
    );
  }

  Future<void> _handleNotificationAction({
    required NotificationItem notification,
    required NotificationNavigationHandler handler,
  }) async {
    if (notification.type != NotificationType.missedCall) {
      final bool handled = handler.handleNotificationTap(notification);
      if (!handled) {
        appLogger.w(
          'Notification action has no supported destination '
          '(id=${notification.id}, type=${notification.type.value})',
        );
      }
      return;
    }

    final String? callerUserId = _clean(
      notification.actorId ??
          notification.payload.otherUser ??
          notification.payload.userId,
    );
    if (callerUserId == null) {
      _showActionFailure('Caller information is unavailable.');
      return;
    }

    final String callerDisplayName =
        _clean(
          notification.payload.actorName ??
              notification.payload.otherUserName ??
              notification.actorName,
        ) ??
        callerUserId;
    final String? callerAvatar = _clean(
      notification.payload.actorAvatar ?? notification.actorAvatar,
    );
    final String callStartingMessage = context.l10n.chat_calling;
    final String callFailureMessage = context.l10n.chat_failed_to_start_call;
    final callbackService = ref.read(missedCallCallbackServiceProvider);
    final coordinator = ref.read(
      notificationMissedCallActionCoordinatorProvider,
    );

    final NotificationMissedCallActionOutcome outcome = await coordinator.run(
      originalCallId: notification.payload.callId,
      start: () => callbackService.callBack(
        callerUserId: callerUserId,
        callerDisplayName: callerDisplayName,
        callerAvatarUrl: callerAvatar,
        originalCallId: notification.payload.callId,
      ),
    );

    switch (outcome) {
      case NotificationMissedCallActionOutcome.started:
        return;
      case NotificationMissedCallActionOutcome.alreadyStarting:
        _showActionFailure(callStartingMessage);
        return;
      case NotificationMissedCallActionOutcome.callInProgress:
        _showActionFailure(callFailureMessage);
        return;
      case NotificationMissedCallActionOutcome.recoveryFailed:
      case NotificationMissedCallActionOutcome.startFailed:
        _showActionFailure(callFailureMessage);
        return;
    }
  }

  void _showActionFailure(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _clean(Object? value) {
    final String? text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}

enum _NotificationMenuAction { markAllRead, clear }
