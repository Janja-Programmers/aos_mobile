import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';

class NotificationState {
  const NotificationState({
    required this.items,
    required this.category,
    required this.unreadCount,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasLoaded,
    this.nextCursor,
    this.errorMessage,
  });

  final List<NotificationItem> items;
  final NotificationCategory category;
  final int unreadCount;
  final String? nextCursor;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasLoaded;
  final String? errorMessage;

  factory NotificationState.initial() {
    return const NotificationState(
      items: <NotificationItem>[],
      category: NotificationCategory.all,
      unreadCount: 0,
      isLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      hasLoaded: false,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  NotificationState copyWith({
    List<NotificationItem>? items,
    NotificationCategory? category,
    int? unreadCount,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      items: items ?? this.items,
      category: category ?? this.category,
      unreadCount: unreadCount ?? this.unreadCount,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
