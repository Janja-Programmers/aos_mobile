import 'dart:convert';

import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/pending_callkit_action_replayer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const store = CallKitPendingPayloadStore();
  final now = DateTime(2026, 8, 26, 20);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> seedAction({
    PendingCallKitAction action = PendingCallKitAction.accept,
    DateTime? createdAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      CallKitPendingPayloadStore.actionKey,
      jsonEncode(<String, dynamic>{
        'call_id': 'CALL-2026-00001',
        'action': action.name,
        'created_at_ms': (createdAt ?? now).millisecondsSinceEpoch,
      }),
    );
    await store.save(<String, dynamic>{
      'call_id': 'CALL-2026-00001',
      'event': 'aos_incoming_call',
    });
  }

  test(
    'resolved action is deduped and clears its stale ringing payload',
    () async {
      await seedAction();
      var executions = 0;

      final replayer = PendingCallKitActionReplayer(
        now: () => now,
        actionExecutor:
            ({
              required PendingCallKitAction action,
              required String callId,
            }) async {
              executions += 1;
              expect(action, PendingCallKitAction.accept);
              expect(callId, 'CALL-2026-00001');
              return true;
            },
      );

      expect(await replayer.replay(), PendingCallKitActionReplayResult.handled);
      expect(executions, 1);
      expect(await store.readAction(), isNull);
      expect(await store.read(), isNull);
      expect(
        await store.wasActionHandled(
          callId: 'CALL-2026-00001',
          action: PendingCallKitAction.accept,
        ),
        isTrue,
      );
    },
  );

  test(
    'transiently unresolved action remains pending and wins over ringing',
    () async {
      await seedAction(action: PendingCallKitAction.decline);

      final replayer = PendingCallKitActionReplayer(
        now: () => now,
        actionExecutor:
            ({
              required PendingCallKitAction action,
              required String callId,
            }) async => false,
      );

      expect(
        await replayer.replay(),
        PendingCallKitActionReplayResult.retryPending,
      );
      expect(await store.readAction(), isNotNull);
      expect(await store.read(), isNotNull);
    },
  );

  test('executor exception retains action for retry', () async {
    await seedAction();

    final replayer = PendingCallKitActionReplayer(
      now: () => now,
      actionExecutor:
          ({
            required PendingCallKitAction action,
            required String callId,
          }) async => throw StateError('offline'),
    );

    expect(
      await replayer.replay(),
      PendingCallKitActionReplayResult.retryPending,
    );
    expect(await store.readAction(), isNotNull);
  });

  test(
    'expired native action and matching ringing payload are discarded',
    () async {
      await seedAction(
        createdAt: now.subtract(
          PendingCallKitActionReplayer.pendingActionMaxAge,
        ),
      );
      var executions = 0;

      final replayer = PendingCallKitActionReplayer(
        now: () => now,
        actionExecutor:
            ({
              required PendingCallKitAction action,
              required String callId,
            }) async {
              executions += 1;
              return true;
            },
      );

      expect(
        await replayer.replay(),
        PendingCallKitActionReplayResult.discarded,
      );
      expect(executions, 0);
      expect(await store.readAction(), isNull);
      expect(await store.read(), isNull);
    },
  );
}
