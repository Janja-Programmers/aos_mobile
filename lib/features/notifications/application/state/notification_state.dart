import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';

class NotificationState {
  final List<NotificationItem> items;

  final bool isLoading;
  final bool isRefreshing;

  final String? errorMessage;

  const NotificationState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    this.errorMessage,
  });

  // =====================================================
  // INITIAL
  // =====================================================
  factory NotificationState.initial() {
    return const NotificationState(
      items: [],
      isLoading: false,
      isRefreshing: false,
    );
  }

  // =====================================================
  // COMPUTED
  // =====================================================

  /// Derived unread count (single source of truth)
  int get unreadCount => items.where((n) => !n.isRead).length;

  /// Whether there are no notifications
  bool get isEmpty => items.isEmpty;

  /// Whether initial load has happened
  bool get hasData => items.isNotEmpty;

  // =====================================================
  // COPY WITH
  // =====================================================
  NotificationState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  // =====================================================
  // HELPERS (STATE TRANSITIONS)
  // =====================================================

  NotificationState loading() {
    return copyWith(isLoading: true);
  }

  NotificationState refreshing() {
    return copyWith(isRefreshing: true);
  }

  NotificationState success(List<NotificationItem> newItems) {
    return copyWith(items: newItems, isLoading: false, isRefreshing: false);
  }

  NotificationState failure(String message) {
    return copyWith(
      isLoading: false,
      isRefreshing: false,
      errorMessage: message,
    );
  }
}
