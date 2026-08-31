import 'dart:async';
import 'dart:math' as math;

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/notifications/application/state/notification_state.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_page.dart';
import 'package:flutter_riverpod/legacy.dart';

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController(this._repository) : super(NotificationState.initial());

  static const int _pageSize = 20;

  final NotificationRepository _repository;
  final Set<String> _readingIds = <String>{};
  final Set<String> _deletingIds = <String>{};

  int _requestGeneration = 0;
  int _stateEpoch = 0;
  bool _isDisposed = false;
  bool _markAllInFlight = false;
  bool _clearInFlight = false;
  int _activeMutations = 0;
  Completer<void>? _mutationsIdleCompleter;

  Future<void> loadNotifications({NotificationCategory? category}) async {
    final NotificationCategory target = category ?? state.category;
    await _loadFirstPage(target, refreshing: false);
  }

  Future<void> selectCategory(NotificationCategory category) async {
    if (category == state.category && state.hasLoaded) return;
    await _loadFirstPage(category, refreshing: false);
  }

  Future<void> refreshNotifications() async {
    await _loadFirstPage(state.category, refreshing: true);
  }

  Future<void> _loadFirstPage(
    NotificationCategory category, {
    required bool refreshing,
  }) async {
    final bool categoryChanged = category != state.category;
    final int generation = ++_requestGeneration;
    state = state.copyWith(
      items: categoryChanged ? const <NotificationItem>[] : null,
      category: category,
      isLoading: categoryChanged || !refreshing,
      isRefreshing: !categoryChanged && refreshing,
      isLoadingMore: false,
      hasLoaded: !categoryChanged && state.hasLoaded,
      clearNextCursor: true,
      clearError: true,
    );

    final Either<Failure, NotificationPage> result = await _repository
        .getNotifications(category: category, limit: _pageSize);
    if (_isDisposed || generation != _requestGeneration) return;

    final Failure? failure = result.leftOrNull;
    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        hasLoaded: state.hasLoaded,
        errorMessage: failure.message,
      );
      return;
    }

    final NotificationPage page = result.rightOrNull!;
    state = state.copyWith(
      items: _sortAndDedupe(page.items),
      category: category,
      unreadCount: math.max(0, page.unreadCount),
      nextCursor: page.nextCursor,
      clearNextCursor: page.nextCursor == null,
      isLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      hasLoaded: true,
      clearError: true,
    );
  }

  Future<void> loadMore() async {
    final String? cursor = state.nextCursor;
    if (state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        cursor == null ||
        cursor.isEmpty) {
      return;
    }

    final int generation = _requestGeneration;
    final NotificationCategory category = state.category;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    final Either<Failure, NotificationPage> result = await _repository
        .getNotifications(category: category, limit: _pageSize, before: cursor);
    if (_isDisposed ||
        generation != _requestGeneration ||
        category != state.category) {
      return;
    }

    final Failure? failure = result.leftOrNull;
    if (failure != null) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      );
      return;
    }

    final NotificationPage page = result.rightOrNull!;
    state = state.copyWith(
      items: _mergePages(state.items, page.items),
      unreadCount: math.max(0, page.unreadCount),
      nextCursor: page.nextCursor,
      clearNextCursor: page.nextCursor == null,
      isLoadingMore: false,
      clearError: true,
    );
  }

  Future<void> markNotificationRead(String notificationId) async {
    if (_clearInFlight ||
        notificationId.isEmpty ||
        !_readingIds.add(notificationId)) {
      return;
    }
    _beginMutation();
    final int epoch = _stateEpoch;
    try {
      final int index = state.items.indexWhere(
        (NotificationItem item) => item.id == notificationId,
      );
      if (index == -1 || state.items[index].isRead) return;

      final List<NotificationItem> items = List<NotificationItem>.of(
        state.items,
      );
      items[index] = items[index].copyWith(isRead: true);
      state = state.copyWith(
        items: items,
        unreadCount: math.max(0, state.unreadCount - 1),
        clearError: true,
      );

      final Either<Failure, NotificationMutationResult> result =
          await _repository.markNotificationRead(notificationId);
      if (_isDisposed || epoch != _stateEpoch) return;
      final Failure? failure = result.leftOrNull;
      if (failure != null) {
        if (!_clearInFlight) {
          await _reconcileAfterMutationFailure(failure.message);
        }
        return;
      }
      state = state.copyWith(
        unreadCount: math.max(0, result.rightOrNull!.unreadCount),
      );
    } finally {
      _readingIds.remove(notificationId);
      _endMutation();
    }
  }

  Future<void> markAllAsRead() async {
    if (_clearInFlight || _markAllInFlight || state.unreadCount <= 0) return;
    _markAllInFlight = true;
    _beginMutation();
    final int epoch = _stateEpoch;
    try {
      state = state.copyWith(
        items: state.items
            .map(
              (NotificationItem item) =>
                  item.isRead ? item : item.copyWith(isRead: true),
            )
            .toList(growable: false),
        unreadCount: 0,
        clearError: true,
      );

      final Either<Failure, NotificationMutationResult> result =
          await _repository.markAllAsRead();
      if (_isDisposed || epoch != _stateEpoch) return;
      final Failure? failure = result.leftOrNull;
      if (failure != null) {
        if (!_clearInFlight) {
          await _reconcileAfterMutationFailure(failure.message);
        }
        return;
      }
      state = state.copyWith(
        unreadCount: math.max(0, result.rightOrNull!.unreadCount),
      );
    } finally {
      _markAllInFlight = false;
      _endMutation();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (_clearInFlight ||
        notificationId.isEmpty ||
        !_deletingIds.add(notificationId)) {
      return;
    }
    _beginMutation();
    final int epoch = _stateEpoch;
    try {
      final int index = state.items.indexWhere(
        (NotificationItem item) => item.id == notificationId,
      );
      if (index == -1) return;

      final NotificationItem target = state.items[index];
      final bool invalidatesCursor = state.nextCursor == notificationId;
      final List<NotificationItem> items = List<NotificationItem>.of(
        state.items,
      )..removeAt(index);
      state = state.copyWith(
        items: items,
        unreadCount: target.isRead
            ? state.unreadCount
            : math.max(0, state.unreadCount - 1),
        isLoadingMore: false,
        clearError: true,
      );
      _requestGeneration++;

      final Either<Failure, NotificationMutationResult> result =
          await _repository.deleteNotification(notificationId);
      if (_isDisposed || epoch != _stateEpoch) return;
      final Failure? failure = result.leftOrNull;
      if (failure != null) {
        if (!_clearInFlight) {
          await _reconcileAfterMutationFailure(failure.message);
        }
        return;
      }

      state = state.copyWith(
        unreadCount: math.max(0, result.rightOrNull!.unreadCount),
      );
      if (invalidatesCursor) await refreshNotifications();
    } finally {
      _deletingIds.remove(notificationId);
      _endMutation();
    }
  }

  Future<void> clearCurrentCategory() async {
    if (_clearInFlight || !state.hasLoaded) return;
    _clearInFlight = true;
    final int epoch = _stateEpoch;
    final NotificationCategory category = state.category;
    try {
      _requestGeneration++;
      state = state.copyWith(
        items: const <NotificationItem>[],
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        clearNextCursor: true,
        clearError: true,
      );

      // `delete_notification` is not idempotent for a row removed by a
      // concurrent clear. Freeze new point mutations and let existing ones
      // settle before issuing the backend batch clear.
      await _waitForMutationsToSettle();
      if (_isDisposed || epoch != _stateEpoch) return;

      final Either<Failure, NotificationMutationResult> result =
          await _repository.clearNotifications(category);
      if (_isDisposed || epoch != _stateEpoch) return;
      final Failure? failure = result.leftOrNull;
      if (failure != null) {
        await _reconcileAfterMutationFailure(failure.message);
        return;
      }

      final int unreadCount = math.max(0, result.rightOrNull!.unreadCount);
      final NotificationCategory current = state.category;
      if (current == category) {
        state = state.copyWith(
          items: const <NotificationItem>[],
          unreadCount: unreadCount,
          clearNextCursor: true,
          hasLoaded: true,
        );
      } else if (category == NotificationCategory.all ||
          current == NotificationCategory.all) {
        await refreshNotifications();
      } else {
        state = state.copyWith(unreadCount: unreadCount);
      }
    } finally {
      _clearInFlight = false;
    }
  }

  void _beginMutation() {
    _activeMutations++;
    _mutationsIdleCompleter ??= Completer<void>();
  }

  void _endMutation() {
    _activeMutations = math.max(0, _activeMutations - 1);
    if (_activeMutations != 0) return;
    final Completer<void>? completer = _mutationsIdleCompleter;
    _mutationsIdleCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  Future<void> _waitForMutationsToSettle() async {
    if (_activeMutations == 0) return;
    final Completer<void>? completer = _mutationsIdleCompleter;
    if (completer != null) await completer.future;
  }

  void upsertNotification(NotificationItem item) {
    if (!state.hasLoaded || !item.hasCanonicalPersistentId) return;
    final bool alreadyPresent = state.items.any(
      (NotificationItem existing) => existing.id == item.id,
    );
    _applyCreated(
      item,
      unreadCount: alreadyPresent || item.isRead
          ? state.unreadCount
          : state.unreadCount + 1,
    );
  }

  void applyRealtimeCreated(NotificationItem item, {required int unreadCount}) {
    if (!item.hasCanonicalPersistentId) return;
    _applyCreated(item, unreadCount: unreadCount);
  }

  void _applyCreated(NotificationItem item, {required int unreadCount}) {
    final NotificationCategory? itemCategory = NotificationCategory.forType(
      item.type,
    );
    final bool visible =
        state.category == NotificationCategory.all ||
        itemCategory == state.category;
    state = state.copyWith(
      items: visible
          ? _mergePages(<NotificationItem>[item], state.items)
          : null,
      unreadCount: math.max(0, unreadCount),
      clearError: true,
    );
  }

  void applyRealtimeRead(String notificationId, {required int unreadCount}) {
    final List<NotificationItem> items = state.items
        .map(
          (NotificationItem item) => item.id == notificationId && !item.isRead
              ? item.copyWith(isRead: true)
              : item,
        )
        .toList(growable: false);
    state = state.copyWith(items: items, unreadCount: math.max(0, unreadCount));
  }

  void applyRealtimeReadAll({required int unreadCount}) {
    state = state.copyWith(
      items: state.items
          .map(
            (NotificationItem item) =>
                item.isRead ? item : item.copyWith(isRead: true),
          )
          .toList(growable: false),
      unreadCount: math.max(0, unreadCount),
    );
  }

  void applyRealtimeDeleted(String notificationId, {required int unreadCount}) {
    final bool invalidatesCursor = state.nextCursor == notificationId;
    state = state.copyWith(
      items: state.items
          .where((NotificationItem item) => item.id != notificationId)
          .toList(growable: false),
      unreadCount: math.max(0, unreadCount),
      clearNextCursor: invalidatesCursor,
    );
    if (invalidatesCursor && state.hasLoaded) {
      unawaited(refreshNotifications());
    }
  }

  void applyRealtimeCleared(
    NotificationCategory category, {
    required int unreadCount,
  }) {
    final List<NotificationItem> items;
    if (category == NotificationCategory.all) {
      items = const <NotificationItem>[];
    } else if (state.category == category) {
      items = const <NotificationItem>[];
    } else if (state.category == NotificationCategory.all) {
      items = state.items
          .where(
            (NotificationItem item) =>
                NotificationCategory.forType(item.type) != category,
          )
          .toList(growable: false);
    } else {
      items = state.items;
    }
    state = state.copyWith(
      items: items,
      unreadCount: math.max(0, unreadCount),
      clearNextCursor:
          category == NotificationCategory.all || state.category == category,
    );
  }

  Future<void> reconcileAfterReconnect() async {
    if (!state.hasLoaded) return;
    await refreshNotifications();
  }

  Future<void> _reconcileAfterMutationFailure(String message) async {
    appLogger.w('Notification mutation failed; reconciling inbox: $message');
    final NotificationCategory category = state.category;
    final int generation = ++_requestGeneration;
    final Either<Failure, NotificationPage> result = await _repository
        .getNotifications(category: category, limit: _pageSize);
    if (_isDisposed ||
        generation != _requestGeneration ||
        state.category != category) {
      return;
    }

    final NotificationPage? page = result.rightOrNull;
    if (page != null) {
      state = state.copyWith(
        items: _sortAndDedupe(page.items),
        unreadCount: math.max(0, page.unreadCount),
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        hasLoaded: true,
        errorMessage: message,
      );
      return;
    }
    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: message,
    );
  }

  void clear() {
    if (_isDisposed) return;
    _stateEpoch++;
    _requestGeneration++;
    _readingIds.clear();
    _deletingIds.clear();
    _markAllInFlight = false;
    _clearInFlight = false;
    _activeMutations = 0;
    final Completer<void>? completer = _mutationsIdleCompleter;
    _mutationsIdleCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
    state = NotificationState.initial();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stateEpoch++;
    _requestGeneration++;
    final Completer<void>? completer = _mutationsIdleCompleter;
    _mutationsIdleCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
    super.dispose();
  }

  List<NotificationItem> _mergePages(
    List<NotificationItem> current,
    List<NotificationItem> incoming,
  ) {
    final Map<String, NotificationItem> byId = <String, NotificationItem>{
      for (final NotificationItem item in current) item.id: item,
    };
    for (final NotificationItem item in incoming) {
      if (item.id.isEmpty) continue;
      final NotificationItem? existing = byId[item.id];
      byId[item.id] = existing == null
          ? item
          : item.copyWith(isRead: item.isRead || existing.isRead);
    }
    return _sortAndDedupe(byId.values.toList(growable: false));
  }

  List<NotificationItem> _sortAndDedupe(List<NotificationItem> source) {
    final Map<String, NotificationItem> byId = <String, NotificationItem>{};
    for (final NotificationItem item in source) {
      if (item.id.isNotEmpty) byId[item.id] = item;
    }
    final List<NotificationItem> items = byId.values.toList(growable: false);
    items.sort(
      (NotificationItem a, NotificationItem b) =>
          b.createdAt.compareTo(a.createdAt),
    );
    return List<NotificationItem>.unmodifiable(items);
  }
}
