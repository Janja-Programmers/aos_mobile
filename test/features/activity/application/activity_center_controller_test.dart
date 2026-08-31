import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/activity/application/activity_center_controller.dart';
import 'package:africaonlinestores/features/activity/data/activity_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads first page and appends the next backend offset page', () async {
    final _FakeActivityRepository repository = _FakeActivityRepository()
      ..listResults.add(
        Either<Failure, ActivityPage>.right(
          ActivityPage(
            items: <ActivityItem>[
              _item('A3', minute: 3),
              _item('A2', minute: 2),
            ],
            total: 3,
            start: 0,
            limit: 20,
            hasMore: true,
          ),
        ),
      )
      ..listResults.add(
        Either<Failure, ActivityPage>.right(
          ActivityPage(
            items: <ActivityItem>[_item('A1', minute: 1)],
            total: 3,
            start: 2,
            limit: 20,
            hasMore: false,
          ),
        ),
      );
    final ActivityCenterController controller = ActivityCenterController(
      repository,
    );

    await controller.load();
    await controller.loadMore();

    expect(repository.listCalls, hasLength(2));
    expect(repository.listCalls.first.start, 0);
    expect(repository.listCalls.last.start, 2);
    expect(controller.state.items.map((ActivityItem item) => item.id), <String>[
      'A3',
      'A2',
      'A1',
    ]);
    expect(controller.state.start, 3);
    expect(controller.state.hasMore, isFalse);
  });

  test('successful hide shifts the consumed offset back by one', () async {
    final _FakeActivityRepository repository = _FakeActivityRepository()
      ..listResults.add(
        Either<Failure, ActivityPage>.right(
          ActivityPage(
            items: <ActivityItem>[
              _item('A3', minute: 3),
              _item('A2', minute: 2),
            ],
            total: 4,
            start: 0,
            limit: 20,
            hasMore: true,
          ),
        ),
      )
      ..listResults.add(
        Either<Failure, ActivityPage>.right(
          ActivityPage(
            items: <ActivityItem>[_item('A1', minute: 1), _item('A0')],
            total: 3,
            start: 1,
            limit: 20,
            hasMore: false,
          ),
        ),
      )
      ..hideResult = Either<Failure, String>.right('A2');
    final ActivityCenterController controller = ActivityCenterController(
      repository,
    );

    await controller.load();
    await controller.hide('A2');

    expect(controller.state.start, 1);
    expect(controller.state.total, 3);
    expect(controller.state.items.map((ActivityItem item) => item.id), <String>[
      'A3',
    ]);

    await controller.loadMore();

    expect(repository.listCalls.last.start, 1);
    expect(controller.state.items.map((ActivityItem item) => item.id), <String>[
      'A3',
      'A1',
      'A0',
    ]);
  });

  test(
    'failed hide reconciles from REST and restores authoritative rows',
    () async {
      final _FakeActivityRepository repository = _FakeActivityRepository()
        ..listResults.add(
          Either<Failure, ActivityPage>.right(
            ActivityPage(
              items: <ActivityItem>[
                _item('A2', minute: 2),
                _item('A1', minute: 1),
              ],
              total: 2,
              start: 0,
              limit: 20,
              hasMore: false,
            ),
          ),
        )
        ..listResults.add(
          Either<Failure, ActivityPage>.right(
            ActivityPage(
              items: <ActivityItem>[
                _item('A2', minute: 2),
                _item('A1', minute: 1),
              ],
              total: 2,
              start: 0,
              limit: 20,
              hasMore: false,
            ),
          ),
        )
        ..hideResult = Either<Failure, String>.left(
          const Failure('Failed to hide activity.'),
        );
      final ActivityCenterController controller = ActivityCenterController(
        repository,
      );

      await controller.load();
      await controller.hide('A2');

      expect(repository.listCalls, hasLength(2));
      expect(
        controller.state.items.map((ActivityItem item) => item.id),
        <String>['A2', 'A1'],
      );
      expect(controller.state.error, 'Failed to hide activity.');
    },
  );

  test('load-more is blocked while a hide mutation is in flight', () async {
    final Completer<Either<Failure, String>> hideCompleter =
        Completer<Either<Failure, String>>();
    final _FakeActivityRepository repository = _FakeActivityRepository()
      ..listResults.add(
        Either<Failure, ActivityPage>.right(
          ActivityPage(
            items: <ActivityItem>[
              _item('A2', minute: 2),
              _item('A1', minute: 1),
            ],
            total: 3,
            start: 0,
            limit: 20,
            hasMore: true,
          ),
        ),
      )
      ..hideHandler = (String id) => hideCompleter.future;
    final ActivityCenterController controller = ActivityCenterController(
      repository,
    );
    await controller.load();

    final Future<void> hideFuture = controller.hide('A2');
    await Future<void>.delayed(Duration.zero);
    await controller.loadMore();

    expect(repository.listCalls, hasLength(1));

    hideCompleter.complete(Either<Failure, String>.right('A2'));
    await hideFuture;
  });

  test(
    'clear waits for an existing hide and does not intermediate-refresh',
    () async {
      final Completer<Either<Failure, String>> hideCompleter =
          Completer<Either<Failure, String>>();
      final _FakeActivityRepository repository = _FakeActivityRepository()
        ..listResults.add(
          Either<Failure, ActivityPage>.right(
            ActivityPage(
              items: <ActivityItem>[
                _item('A2', minute: 2),
                _item('A1', minute: 1),
              ],
              total: 2,
              start: 0,
              limit: 20,
              hasMore: false,
            ),
          ),
        )
        ..hideHandler = (String id) {
          return hideCompleter.future;
        }
        ..clearResult = Either<Failure, int>.right(2);
      final ActivityCenterController controller = ActivityCenterController(
        repository,
      );
      await controller.load(group: 'Ads');

      final Future<void> hideFuture = controller.hide('A2');
      await Future<void>.delayed(Duration.zero);
      final Future<void> clearFuture = controller.clearCurrentGroup();
      await Future<void>.delayed(Duration.zero);

      expect(repository.clearCalls, isEmpty);

      hideCompleter.complete(Either<Failure, String>.right('A2'));
      await hideFuture;
      await clearFuture;

      expect(repository.listCalls, hasLength(1));
      expect(repository.clearCalls, <String?>['Ads']);
      expect(controller.state.items, isEmpty);
      expect(controller.state.total, 0);
      expect(controller.state.hasMore, isFalse);
    },
  );

  test('stale response cannot overwrite a newer group selection', () async {
    final Completer<Either<Failure, ActivityPage>> allPage =
        Completer<Either<Failure, ActivityPage>>();
    final Completer<Either<Failure, ActivityPage>> adsPage =
        Completer<Either<Failure, ActivityPage>>();
    final _FakeActivityRepository repository = _FakeActivityRepository()
      ..listHandler = (_ListCall call) {
        return call.group == 'Ads' ? adsPage.future : allPage.future;
      };
    final ActivityCenterController controller = ActivityCenterController(
      repository,
    );

    final Future<void> first = controller.load();
    final Future<void> second = controller.load(group: 'Ads');

    expect(controller.state.group, 'Ads');
    expect(controller.state.items, isEmpty);
    expect(controller.state.loading, isTrue);
    expect(controller.state.hasLoaded, isFalse);

    adsPage.complete(
      Either<Failure, ActivityPage>.right(
        ActivityPage(
          items: <ActivityItem>[_item('ADS')],
          total: 1,
          start: 0,
          limit: 20,
          hasMore: false,
        ),
      ),
    );
    await second;

    allPage.complete(
      Either<Failure, ActivityPage>.right(
        ActivityPage(
          items: <ActivityItem>[_item('OLD')],
          total: 1,
          start: 0,
          limit: 20,
          hasMore: false,
        ),
      ),
    );
    await first;

    expect(controller.state.group, 'Ads');
    expect(controller.state.items.single.id, 'ADS');
  });
}

ActivityItem _item(String id, {int minute = 0}) {
  return ActivityItem(
    id: id,
    group: 'Ads',
    type: 'ad_view',
    target: ActivityTarget(routeType: 'ad', routeId: 'AD-$id'),
    count: 1,
    occurredAt: DateTime.utc(2026, 8, 31, 10, minute),
    lastOccurrenceAt: DateTime.utc(2026, 8, 31, 10, minute),
  );
}

class _ListCall {
  const _ListCall({
    required this.start,
    required this.limit,
    required this.group,
    required this.type,
  });

  final int start;
  final int limit;
  final String? group;
  final String? type;
}

class _FakeActivityRepository implements ActivityRepository {
  final Queue<Either<Failure, ActivityPage>> listResults =
      Queue<Either<Failure, ActivityPage>>();
  final List<_ListCall> listCalls = <_ListCall>[];
  final List<String> hideCalls = <String>[];
  final List<String?> clearCalls = <String?>[];

  Future<Either<Failure, ActivityPage>> Function(_ListCall call)? listHandler;
  Future<Either<Failure, String>> Function(String id)? hideHandler;
  Either<Failure, String> hideResult = Either<Failure, String>.right('hidden');
  Either<Failure, int> clearResult = Either<Failure, int>.right(0);

  @override
  Future<Either<Failure, ActivityPage>> listActivity({
    int start = 0,
    int limit = 20,
    String? group,
    String? type,
  }) {
    final _ListCall call = _ListCall(
      start: start,
      limit: limit,
      group: group,
      type: type,
    );
    listCalls.add(call);
    final handler = listHandler;
    if (handler != null) return handler(call);
    return Future<Either<Failure, ActivityPage>>.value(
      listResults.removeFirst(),
    );
  }

  @override
  Future<Either<Failure, String>> hideActivity(String activityId) {
    hideCalls.add(activityId);
    final handler = hideHandler;
    if (handler != null) return handler(activityId);
    return Future<Either<Failure, String>>.value(hideResult);
  }

  @override
  Future<Either<Failure, int>> clearActivity({String? group, String? type}) {
    clearCalls.add(group);
    return Future<Either<Failure, int>>.value(clearResult);
  }
}
