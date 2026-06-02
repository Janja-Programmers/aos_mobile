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
      state = state.failure(failure.message);
      return;
    }

    final items = _sortNotifications(result.rightOrNull!);

    state = state.success(items);
  }

  // =====================================================
  // DELETE ONE NOTIFICATION
  // =====================================================
  Future<void> deleteNotification(String notificationId) async {
    final index = state.items.indexWhere((n) => n.id == notificationId);

    if (index == -1) {
      return;
    }

    final previousItems = state.items;

    final updatedItems = [...state.items]
      ..removeWhere((n) => n.id == notificationId);

    state = state.copyWith(items: updatedItems, clearError: true);

    final result = await _repository.deleteNotification(notificationId);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.e(
        'NotificationController -> deleteNotification failed',
        error: failure.message,
      );

      state = state.copyWith(
        items: previousItems,
        errorMessage: failure.message,
      );

      return;
    }
  }

  // =====================================================
  // MARK ONE AS READ
  // =====================================================
  Future<void> markNotificationRead(String notificationId) async {
    final index = state.items.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      return;
    }

    final target = state.items[index];
    if (target.isRead) {
      return;
    }

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
  }

  // =====================================================
  // MARK ALL AS READ
  // =====================================================
  Future<void> markAllAsRead() async {
    if (state.items.isEmpty) {
      return;
    }

    final hasUnread = state.items.any((n) => !n.isRead);
    if (!hasUnread) {
      return;
    }

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
  }

  void restoreNotification(NotificationItem notification, int index) {
    final items = [...state.items];

    final safeIndex = index.clamp(0, items.length);

    items.insert(safeIndex, notification);

    state = state.copyWith(items: items);
  }

  // =====================================================
  // INSERT / MERGE ONE NOTIFICATION
  // For realtime or push payloads already mapped to NotificationItem
  // =====================================================
  void upsertNotification(NotificationItem item) {
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
