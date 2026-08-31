import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/realtime/realtime_event.dart';
import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_realtime_listener.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'consumes canonical Notification Center create and delete actions',
    () async {
      final _FakeRepo repository = _FakeRepo()
        ..pages.add(
          Either<Failure, NotificationPage>.right(
            const NotificationPage(
              category: NotificationCategory.all,
              items: <NotificationItem>[],
              unreadCount: 0,
              nextCursor: null,
            ),
          ),
        );
      final NotificationController controller = NotificationController(
        repository,
      );
      await controller.loadNotifications();

      final StreamController<RealtimeEvent> events =
          StreamController<RealtimeEvent>.broadcast();
      final StreamController<void> connections =
          StreamController<void>.broadcast();
      final NotificationRealtimeListener listener =
          NotificationRealtimeListener(
            eventStream: events.stream,
            connectionStream: connections.stream,
            controller: controller,
          )..attach();

      events.add(
        RealtimeEvent(
          type: RealtimeEventType.unknown,
          eventName: 'aos_notification_center',
          data: <String, dynamic>{
            'version': 1,
            'action': 'created',
            'unread_count': 1,
            'notification': <String, dynamic>{
              'id': 'NOTIF-1',
              'type': 'follow',
              'title': 'New Follower',
              'body': 'Jane followed you',
              'actor': 'ACC-1',
              'actor_display_name': 'Jane',
              'payload': <String, dynamic>{'follower': 'ACC-1'},
              'is_read': false,
              'created_at': '2026-08-31T10:00:00Z',
            },
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.items.single.id, 'NOTIF-1');
      expect(controller.state.unreadCount, 1);

      events.add(
        RealtimeEvent(
          type: RealtimeEventType.unknown,
          eventName: 'aos_notification_center',
          data: <String, dynamic>{
            'version': 1,
            'action': 'deleted',
            'notification_id': 'NOTIF-1',
            'unread_count': 0,
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.items, isEmpty);
      expect(controller.state.unreadCount, 0);

      listener.dispose();
      await events.close();
      await connections.close();
    },
  );

  test('ignores old domain event names even when enum type matches', () async {
    final _FakeRepo repository = _FakeRepo()
      ..pages.add(
        Either<Failure, NotificationPage>.right(
          const NotificationPage(
            category: NotificationCategory.all,
            items: <NotificationItem>[],
            unreadCount: 0,
            nextCursor: null,
          ),
        ),
      );
    final NotificationController controller = NotificationController(
      repository,
    );
    await controller.loadNotifications();

    final StreamController<RealtimeEvent> events =
        StreamController<RealtimeEvent>.broadcast();
    final StreamController<void> connections =
        StreamController<void>.broadcast();
    final NotificationRealtimeListener listener = NotificationRealtimeListener(
      eventStream: events.stream,
      connectionStream: connections.stream,
      controller: controller,
    )..attach();

    events.add(
      RealtimeEvent(
        type: RealtimeEventType.aosFollow,
        eventName: 'aos_follow',
        data: <String, dynamic>{'follower': 'ACC-OLD'},
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.items, isEmpty);
    expect(controller.state.unreadCount, 0);

    listener.dispose();
    await events.close();
    await connections.close();
  });

  test('invalid unread count reconciles from REST', () async {
    final _FakeRepo repository = _FakeRepo()
      ..pages.add(
        Either<Failure, NotificationPage>.right(
          const NotificationPage(
            category: NotificationCategory.account,
            items: <NotificationItem>[],
            unreadCount: 0,
            nextCursor: null,
          ),
        ),
      )
      ..pages.add(
        Either<Failure, NotificationPage>.right(
          const NotificationPage(
            category: NotificationCategory.account,
            items: <NotificationItem>[],
            unreadCount: 4,
            nextCursor: null,
          ),
        ),
      );
    final NotificationController controller = NotificationController(
      repository,
    );
    await controller.loadNotifications(category: NotificationCategory.account);

    final StreamController<RealtimeEvent> events =
        StreamController<RealtimeEvent>.broadcast();
    final StreamController<void> connections =
        StreamController<void>.broadcast();
    final NotificationRealtimeListener listener = NotificationRealtimeListener(
      eventStream: events.stream,
      connectionStream: connections.stream,
      controller: controller,
    )..attach();

    events.add(
      RealtimeEvent(
        type: RealtimeEventType.unknown,
        eventName: 'aos_notification_center',
        data: <String, dynamic>{
          'version': 1,
          'action': 'read_all',
          'unread_count': -1,
        },
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 2);
    expect(controller.state.unreadCount, 4);

    listener.dispose();
    await events.close();
    await connections.close();
  });

  test('socket reconnect reconciles the currently selected category', () async {
    final _FakeRepo repository = _FakeRepo()
      ..pages.add(
        Either<Failure, NotificationPage>.right(
          const NotificationPage(
            category: NotificationCategory.account,
            items: <NotificationItem>[],
            unreadCount: 0,
            nextCursor: null,
          ),
        ),
      )
      ..pages.add(
        Either<Failure, NotificationPage>.right(
          const NotificationPage(
            category: NotificationCategory.account,
            items: <NotificationItem>[],
            unreadCount: 3,
            nextCursor: null,
          ),
        ),
      );
    final NotificationController controller = NotificationController(
      repository,
    );
    await controller.loadNotifications(category: NotificationCategory.account);

    final StreamController<RealtimeEvent> events =
        StreamController<RealtimeEvent>.broadcast();
    final StreamController<void> connections =
        StreamController<void>.broadcast();
    final NotificationRealtimeListener listener = NotificationRealtimeListener(
      eventStream: events.stream,
      connectionStream: connections.stream,
      controller: controller,
    )..attach();

    connections.add(null);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 2);
    expect(controller.state.unreadCount, 3);

    listener.dispose();
    await events.close();
    await connections.close();
  });
}

class _FakeRepo implements NotificationRepository {
  final Queue<Either<Failure, NotificationPage>> pages =
      Queue<Either<Failure, NotificationPage>>();
  int calls = 0;

  @override
  Future<Either<Failure, NotificationPage>> getNotifications({
    required NotificationCategory category,
    required int limit,
    String? before,
  }) async {
    calls += 1;
    return pages.removeFirst();
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> clearNotifications(
    NotificationCategory category,
  ) async {
    return Either<Failure, NotificationMutationResult>.right(
      NotificationMutationResult(unreadCount: 0, category: category),
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> deleteNotification(
    String notificationId,
  ) async {
    return Either<Failure, NotificationMutationResult>.right(
      NotificationMutationResult(
        unreadCount: 0,
        notificationId: notificationId,
      ),
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> markAllAsRead() async {
    return Either<Failure, NotificationMutationResult>.right(
      const NotificationMutationResult(unreadCount: 0),
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> markNotificationRead(
    String notificationId,
  ) async {
    return Either<Failure, NotificationMutationResult>.right(
      NotificationMutationResult(
        unreadCount: 0,
        notificationId: notificationId,
      ),
    );
  }
}
