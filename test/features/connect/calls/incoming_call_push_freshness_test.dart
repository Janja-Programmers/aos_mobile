import 'package:africaonlinestores/features/connect/calls/platform/callkit/incoming_call_push_freshness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 26, 20);

  test('incoming-call push younger than backend TTL is fresh', () {
    expect(
      isIncomingCallPushFresh(
        sentTime: now.subtract(const Duration(seconds: 29)),
        now: now,
      ),
      isTrue,
    );
  });

  test('incoming-call push at backend TTL boundary is stale', () {
    expect(
      isIncomingCallPushFresh(
        sentTime: now.subtract(const Duration(seconds: 30)),
        now: now,
      ),
      isFalse,
    );
  });

  test('incoming-call push older than backend TTL is stale', () {
    expect(
      isIncomingCallPushFresh(
        sentTime: now.subtract(const Duration(seconds: 31)),
        now: now,
      ),
      isFalse,
    );
  });

  test('missing FCM sentTime is allowed for backend reconciliation', () {
    expect(isIncomingCallPushFresh(sentTime: null, now: now), isTrue);
  });

  test('future sentTime is tolerated for clock skew', () {
    expect(
      isIncomingCallPushFresh(
        sentTime: now.add(const Duration(seconds: 2)),
        now: now,
      ),
      isTrue,
    );
  });
}
