import 'package:flutter_test/flutter_test.dart';

import 'fake_session_storage.dart';

void main() {
  test(
    'fake session storage persists and clears auth values in memory',
    () async {
      final FakeSessionStorage storage = FakeSessionStorage();

      await storage.setSid('sid-1');
      await storage.setRememberMe(false);
      await storage.setRememberedEmail('user@example.invalid');

      expect(await storage.getSid(), 'sid-1');
      expect(await storage.getRememberMe(), isFalse);
      expect(await storage.getRememberedEmail(), 'user@example.invalid');

      await storage.clearSid();
      await storage.clearRememberedEmail();

      expect(await storage.getSid(), isNull);
      expect(await storage.getRememberedEmail(), isEmpty);
    },
  );
}
