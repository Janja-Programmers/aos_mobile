import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';

class NotificationRealtimeListener {
  NotificationRealtimeListener({
    required Stream<RealtimeEvent> eventStream,
    required Stream<void> connectionStream,
    required NotificationController controller,
  }) : _eventStream = eventStream,
       _connectionStream = connectionStream,
       _controller = controller;

  static const String _eventName = 'aos_notification_center';
  static const int _version = 1;
  static const int _tombstoneCapacity = 256;

  final Stream<RealtimeEvent> _eventStream;
  final Stream<void> _connectionStream;
  final NotificationController _controller;
  final LinkedHashSet<String> _deletedIds = LinkedHashSet<String>();

  StreamSubscription<RealtimeEvent>? _eventSub;
  StreamSubscription<void>? _connectionSub;
  Future<void> _tail = Future<void>.value();

  void attach() {
    if (_eventSub != null) return;
    _eventSub = _eventStream.listen(
      _enqueue,
      onError: (Object error, StackTrace stackTrace) {
        appLogger.e(
          'Notification realtime stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    _connectionSub = _connectionStream.listen((_) {
      _tail = _tail.then<void>((_) => _controller.reconcileAfterReconnect());
    });
  }

  void _enqueue(RealtimeEvent event) {
    if (event.eventName != _eventName) return;
    _tail = _tail.then<void>((_) => _handle(event)).onError((
      Object error,
      StackTrace stackTrace,
    ) {
      appLogger.e(
        'Notification realtime event failed',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  Future<void> _handle(RealtimeEvent event) async {
    final Map<String, dynamic> data = asJsonMap(event.data);
    if (_asInt(data['version']) != _version) {
      appLogger.w('Ignoring unsupported notification realtime version');
      return;
    }

    final String action = data['action']?.toString().trim().toLowerCase() ?? '';
    final int? unreadCountValue = _asInt(data['unread_count']);
    if (unreadCountValue == null || unreadCountValue < 0) {
      appLogger.w('Notification realtime event has invalid unread_count');
      await _controller.reconcileAfterReconnect();
      return;
    }
    final int unreadCount = unreadCountValue;

    switch (action) {
      case 'created':
        final Map<String, dynamic> rawNotification = asJsonMap(
          data['notification'],
        );
        final NotificationItem item = NotificationItem.fromJson(
          rawNotification,
        );
        if (!item.hasCanonicalPersistentId) return;
        if (_deletedIds.remove(item.id)) {
          await _controller.reconcileAfterReconnect();
          return;
        }
        _controller.applyRealtimeCreated(item, unreadCount: unreadCount);
        return;
      case 'read':
        final String? id = _clean(data['notification_id']);
        if (id != null) {
          _controller.applyRealtimeRead(id, unreadCount: unreadCount);
        }
        return;
      case 'read_all':
        _controller.applyRealtimeReadAll(unreadCount: unreadCount);
        return;
      case 'deleted':
        final String? id = _clean(data['notification_id']);
        if (id != null) {
          _rememberDeleted(id);
          _controller.applyRealtimeDeleted(id, unreadCount: unreadCount);
        }
        return;
      case 'cleared':
        final NotificationCategory? category =
            NotificationCategory.tryFromBackendValue(data['category']);
        if (category == null) {
          await _controller.reconcileAfterReconnect();
          return;
        }
        _controller.applyRealtimeCleared(category, unreadCount: unreadCount);
        // Clear can race with an older `created` transport frame. The inbox is
        // authoritative, so reconcile immediately instead of inventing event
        // ordering rules the backend does not expose.
        await _controller.reconcileAfterReconnect();
        return;
      default:
        appLogger.w('Ignoring unknown notification realtime action: $action');
    }
  }

  void _rememberDeleted(String id) {
    _deletedIds.add(id);
    while (_deletedIds.length > _tombstoneCapacity) {
      _deletedIds.remove(_deletedIds.first);
    }
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? _clean(Object? value) {
    final String? text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  void dispose() {
    unawaited(_eventSub?.cancel());
    unawaited(_connectionSub?.cancel());
    _eventSub = null;
    _connectionSub = null;
    _deletedIds.clear();
  }
}
