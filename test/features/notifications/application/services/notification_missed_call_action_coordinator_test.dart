import 'dart:async';

import 'package:africaonlinestores/features/notifications/application/services/notification_missed_call_action_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reconciles Calls lifecycle before delegating callback start', () async {
    final List<String> events = <String>[];
    final NotificationMissedCallActionCoordinator coordinator =
        NotificationMissedCallActionCoordinator(
          recoverCallLifecycle: (String? originalCallId) async {
            events.add('recover:$originalCallId');
          },
          isCallLifecycleBusy: () {
            events.add('busy-check');
            return false;
          },
        );

    final NotificationMissedCallActionOutcome outcome = await coordinator.run(
      originalCallId: 'CALL-0001',
      start: () async {
        events.add('start');
        return true;
      },
    );

    expect(outcome, NotificationMissedCallActionOutcome.started);
    expect(events, <String>['recover:CALL-0001', 'busy-check', 'start']);
  });

  test('does not start another call when Calls lifecycle is busy', () async {
    var startCount = 0;
    final NotificationMissedCallActionCoordinator coordinator =
        NotificationMissedCallActionCoordinator(
          recoverCallLifecycle: (String? _) async {},
          isCallLifecycleBusy: () => true,
        );

    final NotificationMissedCallActionOutcome outcome = await coordinator.run(
      start: () async {
        startCount += 1;
        return true;
      },
    );

    expect(outcome, NotificationMissedCallActionOutcome.callInProgress);
    expect(startCount, 0);
  });

  test('repeated taps are single-flight', () async {
    final Completer<bool> startCompleter = Completer<bool>();
    var startCount = 0;
    final NotificationMissedCallActionCoordinator coordinator =
        NotificationMissedCallActionCoordinator(
          recoverCallLifecycle: (String? _) async {},
          isCallLifecycleBusy: () => false,
        );

    final Future<NotificationMissedCallActionOutcome> first = coordinator.run(
      start: () {
        startCount += 1;
        return startCompleter.future;
      },
    );
    await Future<void>.delayed(Duration.zero);

    final NotificationMissedCallActionOutcome second = await coordinator.run(
      start: () async {
        startCount += 1;
        return true;
      },
    );

    expect(second, NotificationMissedCallActionOutcome.alreadyStarting);
    expect(startCount, 1);

    startCompleter.complete(true);
    expect(await first, NotificationMissedCallActionOutcome.started);
  });

  test('recovery failure never enters outgoing Calls start', () async {
    var startCount = 0;
    final NotificationMissedCallActionCoordinator coordinator =
        NotificationMissedCallActionCoordinator(
          recoverCallLifecycle: (String? _) async {
            throw StateError('recovery failed');
          },
          isCallLifecycleBusy: () => false,
        );

    final NotificationMissedCallActionOutcome outcome = await coordinator.run(
      start: () async {
        startCount += 1;
        return true;
      },
    );

    expect(outcome, NotificationMissedCallActionOutcome.recoveryFailed);
    expect(startCount, 0);
  });

  test(
    'false and thrown delegate starts are reported as start failures',
    () async {
      final NotificationMissedCallActionCoordinator coordinator =
          NotificationMissedCallActionCoordinator(
            recoverCallLifecycle: (String? _) async {},
            isCallLifecycleBusy: () => false,
          );

      expect(
        await coordinator.run(start: () async => false),
        NotificationMissedCallActionOutcome.startFailed,
      );

      expect(
        await coordinator.run(
          start: () async {
            throw StateError('start failed');
          },
        ),
        NotificationMissedCallActionOutcome.startFailed,
      );
    },
  );
}
