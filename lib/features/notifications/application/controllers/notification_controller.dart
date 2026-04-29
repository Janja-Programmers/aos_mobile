import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/notifications/application/state/notification_state.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';

class NotificationController extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationController(this._repository) : super(NotificationState.initial());

  // =====================================================
  // LOAD
  // =====================================================
  Future<void> loadNotifications() async {
    if (state.isLoading) return;

    state = state.loading();

    final result = await _repository.getNotifications();

    if (result.isLeft) {
      final failure = result.leftOrNull!;
      appLogger.w(
        'NotificationController -> loadNotifications failed: ${failure.message}',
      );
      state = state.failure(failure.message);
      return;
    }

    final items = _sortNotifications(result.rightOrNull!);

    state = state.success(items);
  }

  // =====================================================
  // REFRESH
  // =====================================================
  Future<void> refreshNotifications() async {
    if (state.isRefreshing) return;

    state = state.refreshing();

    final result = await _repository.getNotifications();

    if (result.isLeft) {
      final failure = result.leftOrNull!;
      appLogger.w(
        'NotificationController -> refreshNotifications failed: ${failure.message}',
      );
      state = state.failure(failure.message);
      return;
    }

    final items = _sortNotifications(result.rightOrNull!);

    state = state.success(items);
  }

  // =====================================================
  // MARK ONE AS READ
  // =====================================================
  Future<void> markNotificationRead(String notificationId) async {
    final index = state.items.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      appLogger.w(
        'NotificationController -> markNotificationRead skipped: not found ($notificationId)',
      );
      return;
    }

    final target = state.items[index];
    if (target.isRead) {
      appLogger.i(
        'NotificationController -> markNotificationRead skipped: already read ($notificationId)',
      );
      return;
    }

    appLogger.i(
      'NotificationController -> markNotificationRead optimistic: $notificationId',
    );

    final previousItems = state.items;

    final updatedItems = [...state.items];
    updatedItems[index] = updatedItems[index].copyWith(isRead: true);

    state = state.copyWith(items: updatedItems, clearError: true);

    final result = await _repository.markNotificationRead(notificationId);

    if (result.isLeft) {
      final failure = result.leftOrNull!;
      appLogger.e(
        'NotificationController -> markNotificationRead failed',
        error: failure.message,
      );

      state = state.copyWith(
        items: previousItems,
        errorMessage: failure.message,
      );
      return;
    }

    appLogger.i(
      'NotificationController -> markNotificationRead success: $notificationId',
    );
  }

  // =====================================================
  // MARK ALL AS READ
  // =====================================================
  Future<void> markAllAsRead() async {
    if (state.items.isEmpty) {
      appLogger.i('NotificationController -> markAllAsRead skipped: no items');
      return;
    }

    final hasUnread = state.items.any((n) => !n.isRead);
    if (!hasUnread) {
      appLogger.i(
        'NotificationController -> markAllAsRead skipped: all already read',
      );
      return;
    }

    appLogger.i('NotificationController -> markAllAsRead optimistic');

    final previousItems = state.items;
    final updatedItems = state.items
        .map((item) => item.isRead ? item : item.copyWith(isRead: true))
        .toList();

    state = state.copyWith(items: updatedItems, clearError: true);

    final result = await _repository.markAllAsRead();

    if (result.isLeft) {
      final failure = result.leftOrNull!;
      appLogger.e(
        'NotificationController -> markAllAsRead failed',
        error: failure.message,
      );

      state = state.copyWith(
        items: previousItems,
        errorMessage: failure.message,
      );
      return;
    }

    appLogger.i('NotificationController -> markAllAsRead success');
  }

  // =====================================================
  // INSERT / MERGE ONE NOTIFICATION
  // For realtime or push payloads already mapped to NotificationItem
  // =====================================================
  void upsertNotification(NotificationItem item) {
    appLogger.i('NotificationController -> upsertNotification: ${item.id}');

    final existingIndex = state.items.indexWhere((n) => n.id == item.id);

    if (existingIndex == -1) {
      final newItems = _sortNotifications([item, ...state.items]);

      state = state.copyWith(items: newItems, clearError: true);

      return;
    }

    final current = state.items[existingIndex];

    final merged = _mergeNotification(current, item);

    final updatedItems = [...state.items];
    updatedItems[existingIndex] = merged;

    state = state.copyWith(
      items: _sortNotifications(updatedItems),
      clearError: true,
    );
  }

  // =====================================================
  // INSERT MANY / RECONCILE
  // Useful when syncing push/realtime/API together
  // =====================================================
  void reconcileNotifications(List<NotificationItem> incoming) {
    if (incoming.isEmpty) return;

    appLogger.i(
      'NotificationController -> reconcileNotifications: ${incoming.length}',
    );

    final map = <String, NotificationItem>{
      for (final item in state.items) item.id: item,
    };

    for (final item in incoming) {
      final existing = map[item.id];
      map[item.id] = existing == null
          ? item
          : _mergeNotification(existing, item);
    }

    state = state.copyWith(
      items: _sortNotifications(map.values.toList()),
      clearError: true,
    );
  }

  // =====================================================
  // CLEAR
  // =====================================================
  void clear() {
    appLogger.i('NotificationController -> clear');
    state = NotificationState.initial();
  }

  // =====================================================
  // HELPERS
  // =====================================================
  NotificationItem _mergeNotification(
    NotificationItem current,
    NotificationItem incoming,
  ) {
    return NotificationItem(
      id: incoming.id,
      type: incoming.type,
      title: incoming.title,
      body: incoming.body,
      actorId: incoming.actorId ?? current.actorId,
      actorName: incoming.actorName ?? current.actorName,
      actorAvatar: incoming.actorAvatar ?? current.actorAvatar,
      isRead: current.isRead || incoming.isRead,
      createdAt: incoming.createdAt,
      payload: incoming.payload,
    );
  }

  List<NotificationItem> _sortNotifications(List<NotificationItem> items) {
    final sorted = [...items];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
}
