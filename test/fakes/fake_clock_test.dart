import 'package:flutter_test/flutter_test.dart';

import 'fake_clock.dart';

void main() {
  test('mutable clock advances deterministically', () {
    final MutableClock clock = MutableClock(DateTime.utc(2026));

    clock.advance(const Duration(hours: 2));

    expect(clock.now(), DateTime.utc(2026, 1, 1, 2));
  });
}
