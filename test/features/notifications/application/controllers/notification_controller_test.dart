import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_page.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and cursor-paginates the selected backend category', () async {
    final _FakeNotificationRepository repository = _FakeNotificationRepository()
      ..listResults.add(
        Either<Failure, NotificationPage>.right(
          NotificationPage(
            category: NotificationCategory.marketplace,
            items: <NotificationItem>[
              _item('N2', NotificationType.adApproved, minute: 2),
              _item('N1', NotificationType.reviewReceived, minute: 1),
            ],
            unreadCount: 7,
            nextCursor: 'N1',
          ),
        ),
      )
      ..listResults.add(
        Either<Failure, NotificationPage>.right(
          NotificationPage(
            category: NotificationCategory.marketplace,
            items: <NotificationItem>[
              _item('N1', NotificationType.reviewReceived, minute: 1),
              _item('N0', NotificationType.adRejected),
            ],
            unreadCount: 7,
            nextCursor: null,
          ),
        ),
      );
    final NotificationController controller = NotificationController(
      repository,
    );

    await controller.loadNotifications(
      category: NotificationCategory.marketplace,
    );
    await controller.loadMore();

    expect(repository.listCalls, hasLength(2));
    expect(
      repository.listCalls.first.category,
      NotificationCategory.marketplace,
    );
    expect(repository.listCalls.first.before, isNull);
    expect(repository.listCalls.last.before, 'N1');
    expect(
      controller.state.items.map((NotificationItem item) => item.id),
      <String>['N2', 'N1', 'N0'],
    );
    expect(controller.state.unreadCount, 7);
    expect(controller.state.hasMore, isFalse);
  });

  test('prevents duplicate concurrent load-more requests', () async {
    final Completer<Either<Failure, NotificationPage>> nextPage =
        Completer<Either<Failure, NotificationPage>>();
    final _FakeNotificationRepository repository = _FakeNotificationRepository()
      ..listResults.add(
        Either<Failure, NotificationPage>.right(
          NotificationPage(
            category: NotificationCategory.all,
            items: <NotificationItem>[_item('N1', NotificationType.follow)],
            unreadCount: 1,
            nextCursor: 'N1',
          ),
        ),
      );
    final NotificationController controller = NotificationController(
      repository,
    );
    await controller.loadNotifications();
    repository.listHandler = (_ListCall call) => nextPage.future;

    final Future<void> first = controller.loadMore();
    final Future<void> second = controller.loadMore();
    await Future<void>.delayed(Duration.zero);

    expect(
      repository.listCalls.where((_ListCall call) => call.before != null),
      hasLength(1),
    );

    nextPage.complete(
      Either<Failure, NotificationPage>.right(
        const NotificationPage(
          category: NotificationCategory.all,
          items: <NotificationItem>[],
          unreadCount: 1,
          nextCursor: null,
        ),
      ),
    );
    await Future.wait<void>(<Future<void>>[first, second]);
  });

  test('ignores a stale response after switching categories', () async {
    final Completer<Either<Failure, NotificationPage>> allPage =
        Completer<Either<Failure, NotificationPage>>();
    final Completer<Either<Failure, NotificationPage>> marketplacePage =
        Completer<Either<Failure, NotificationPage>>();
    final _FakeNotificationRepository repository = _FakeNotificationRepository()
      ..listHandler = (_ListCall call) {
        return call.category == NotificationCategory.marketplace
            ? marketplacePage.future
            : allPage.future;
      };
    final NotificationController controller = NotificationController(
      repository,
    );

    final Future<void> first = controller.loadNotifications();
    final Future<void> second = controller.loadNotifications(
      category: NotificationCategory.marketplace,
    );

    expect(controller.state.category, NotificationCategory.marketplace);
    expect(controller.state.items, isEmpty);
    expect(controller.state.isLoading, isTrue);
    expect(controller.state.hasLoaded, isFalse);

    marketplacePage.complete(
      Either<Failure, NotificationPage>.right(
        NotificationPage(
          category: NotificationCategory.marketplace,
          items: <NotificationItem>[
            _item('MARKET', NotificationType.adApproved),
          ],
          unreadCount: 2,
          nextCursor: null,
        ),
      ),
    );
    await second;

    allPage.complete(
      Either<Failure, NotificationPage>.right(
        NotificationPage(
          category: NotificationCategory.all,
          items: <NotificationItem>[_item('OLD', NotificationType.follow)],
          unreadCount: 9,
          nextCursor: null,
        ),
      ),
    );
    await first;

    expect(controller.state.category, NotificationCategory.marketplace);
    expect(controller.state.items.single.id, 'MARKET');
    expect(controller.state.unreadCount, 2);
  });

  test('uses backend batch clear for the selected category', () async {
    final _FakeNotificationRepository repository = _FakeNotificationRepository()
      ..listResults.add(
        Either<Failure, NotificationPage>.right(
          NotificationPage(
            category: NotificationCategory.account,
            items: <NotificationItem>[
              _item('VERIFY', NotificationType.verificationApproved),
            ],
            unreadCount: 4,
            nextCursor: null,
          ),
        ),
      )
      ..clearResult = Either<Failure, NotificationMutationResult>.right(
        const NotificationMutationResult(
          unreadCount: 3,
          category: NotificationCategory.account,
          deletedCount: 1,
        ),
      );
    final NotificationController controller = NotificationController(
      repository,
    );
    await controller.loadNotifications(category: NotificationCategory.account);

    await controller.clearCurrentCategory();

    expect(repository.clearCategories, <NotificationCategory>[
      NotificationCategory.account,
    ]);
    expect(controller.state.items, isEmpty);
    expect(controller.state.unreadCount, 3);
  });

  test('failed single delete reconciles authoritative page state', () async {
    final NotificationItem row = _item('N1', NotificationType.follow);
    final _FakeNotificationRepository repository = _FakeNotificationRepository()
      ..listResults.add(
        Either<Failure, NotificationPage>.right(
          NotificationPage(
            category: NotificationCategory.all,
            items: <NotificationItem>[row],
            unreadCount: 1,
            nextCursor: null,
          ),
        ),
      )
      ..listResults.add(
        Either<Failure, NotificationPage>.right(
          NotificationPage(
            category: NotificationCategory.all,
            items: <NotificationItem>[row],
            unreadCount: 1,
            nextCursor: null,
          ),
        ),
      )
      ..deleteResult = Either<Failure, NotificationMutationResult>.left(
        const Failure('Delete failed.'),
      );
    final NotificationController controller = NotificationController(
      repository,
    );
    await controller.loadNotifications();

    await controller.deleteNotification('N1');

    expect(repository.listCalls, hasLength(2));
    expect(controller.state.items.single.id, 'N1');
    expect(controller.state.unreadCount, 1);
    expect(controller.state.errorMessage, 'Delete failed.');
  });

  test(
    'clear supersedes a point mutation without intermediate reconcile',
    () async {
      final Completer<Either<Failure, NotificationMutationResult>>
      deleteCompleter =
          Completer<Either<Failure, NotificationMutationResult>>();
      final _FakeNotificationRepository repository =
          _FakeNotificationRepository()
            ..listResults.add(
              Either<Failure, NotificationPage>.right(
                NotificationPage(
                  category: NotificationCategory.all,
                  items: <NotificationItem>[
                    _item('N1', NotificationType.follow),
                  ],
                  unreadCount: 1,
                  nextCursor: null,
                ),
              ),
            )
            ..deleteHandler = (String id) {
              return deleteCompleter.future;
            }
            ..clearResult = Either<Failure, NotificationMutationResult>.right(
              const NotificationMutationResult(
                unreadCount: 0,
                category: NotificationCategory.all,
                deletedCount: 1,
              ),
            );
      final NotificationController controller = NotificationController(
        repository,
      );
      await controller.loadNotifications();

      final Future<void> deleteFuture = controller.deleteNotification('N1');
      await Future<void>.delayed(Duration.zero);
      final Future<void> clearFuture = controller.clearCurrentCategory();
      await Future<void>.delayed(Duration.zero);

      expect(repository.clearCategories, isEmpty);

      deleteCompleter.complete(
        Either<Failure, NotificationMutationResult>.left(
          const Failure('Point delete lost a clear race.'),
        ),
      );
      await deleteFuture;
      await clearFuture;

      expect(repository.listCalls, hasLength(1));
      expect(repository.clearCategories, <NotificationCategory>[
        NotificationCategory.all,
      ]);
      expect(controller.state.items, isEmpty);
      expect(controller.state.unreadCount, 0);
    },
  );

  test(
    'realtime create only inserts rows visible in the selected domain',
    () async {
      final _FakeNotificationRepository repository =
          _FakeNotificationRepository()
            ..listResults.add(
              Either<Failure, NotificationPage>.right(
                const NotificationPage(
                  category: NotificationCategory.account,
                  items: <NotificationItem>[],
                  unreadCount: 0,
                  nextCursor: null,
                ),
              ),
            );
      final NotificationController controller = NotificationController(
        repository,
      );
      await controller.loadNotifications(
        category: NotificationCategory.account,
      );

      controller.applyRealtimeCreated(
        _item('FOLLOW', NotificationType.follow),
        unreadCount: 1,
      );
      expect(controller.state.items, isEmpty);
      expect(controller.state.unreadCount, 1);

      controller.applyRealtimeCreated(
        _item('VERIFY', NotificationType.verificationApproved),
        unreadCount: 2,
      );
      expect(controller.state.items.single.id, 'VERIFY');
      expect(controller.state.unreadCount, 2);
    },
  );
}

NotificationItem _item(String id, NotificationType type, {int minute = 0}) {
  return NotificationItem(
    id: id,
    type: type,
    title: id,
    body: 'body',
    isRead: false,
    createdAt: DateTime.utc(2026, 8, 31, 10, minute),
    payload: const NotificationPayload(),
  );
}

class _ListCall {
  const _ListCall({
    required this.category,
    required this.limit,
    required this.before,
  });

  final NotificationCategory category;
  final int limit;
  final String? before;
}

class _FakeNotificationRepository implements NotificationRepository {
  final Queue<Either<Failure, NotificationPage>> listResults =
      Queue<Either<Failure, NotificationPage>>();
  final List<_ListCall> listCalls = <_ListCall>[];
  final List<NotificationCategory> clearCategories = <NotificationCategory>[];

  Future<Either<Failure, NotificationPage>> Function(_ListCall call)?
  listHandler;
  Future<Either<Failure, NotificationMutationResult>> Function(String id)?
  deleteHandler;

  Either<Failure, NotificationMutationResult> readResult =
      Either<Failure, NotificationMutationResult>.right(
        const NotificationMutationResult(unreadCount: 0),
      );
  Either<Failure, NotificationMutationResult> markAllResult =
      Either<Failure, NotificationMutationResult>.right(
        const NotificationMutationResult(unreadCount: 0),
      );
  Either<Failure, NotificationMutationResult> deleteResult =
      Either<Failure, NotificationMutationResult>.right(
        const NotificationMutationResult(unreadCount: 0),
      );
  Either<Failure, NotificationMutationResult> clearResult =
      Either<Failure, NotificationMutationResult>.right(
        const NotificationMutationResult(unreadCount: 0),
      );

  @override
  Future<Either<Failure, NotificationPage>> getNotifications({
    required NotificationCategory category,
    required int limit,
    String? before,
  }) {
    final _ListCall call = _ListCall(
      category: category,
      limit: limit,
      before: before,
    );
    listCalls.add(call);
    final handler = listHandler;
    if (handler != null) return handler(call);
    return Future<Either<Failure, NotificationPage>>.value(
      listResults.removeFirst(),
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> markNotificationRead(
    String notificationId,
  ) {
    return Future<Either<Failure, NotificationMutationResult>>.value(
      readResult,
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> markAllAsRead() {
    return Future<Either<Failure, NotificationMutationResult>>.value(
      markAllResult,
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> deleteNotification(
    String notificationId,
  ) {
    final handler = deleteHandler;
    if (handler != null) return handler(notificationId);
    return Future<Either<Failure, NotificationMutationResult>>.value(
      deleteResult,
    );
  }

  @override
  Future<Either<Failure, NotificationMutationResult>> clearNotifications(
    NotificationCategory category,
  ) {
    clearCategories.add(category);
    return Future<Either<Failure, NotificationMutationResult>>.value(
      clearResult,
    );
  }
}
