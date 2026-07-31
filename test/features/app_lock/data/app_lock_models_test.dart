import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timeout storage values round trip and legacy values migrate', () {
    for (final AppLockTimeout timeout in AppLockTimeout.values) {
      expect(AppLockTimeout.fromStorage(timeout.storageValue), timeout);
    }
    expect(
      AppLockTimeout.fromStorage('oneMinute'),
      AppLockTimeout.thirtySeconds,
    );
    expect(
      AppLockTimeout.fromStorage('fiveMinutes'),
      AppLockTimeout.thirtySeconds,
    );
    expect(AppLockTimeout.fromStorage('invalid'), AppLockTimeout.immediately);
  });

  test('unconfigured state never blocks protected content', () {
    expect(AppLockState.initial.blocksProtectedContent, isFalse);
    expect(
      const AppLockState(
        phase: AppLockPhase.locked,
        preference: AppLockPreference.disabled,
      ).blocksProtectedContent,
      isFalse,
    );
  });

  test('authenticated initialization and storage failure fail closed', () {
    expect(
      AppLockState.initial
          .copyWith(accountId: 'one@example.com')
          .blocksProtectedContent,
      isTrue,
    );
    expect(
      const AppLockState(
        phase: AppLockPhase.unavailable,
        preference: AppLockPreference.disabled,
        accountId: 'one@example.com',
      ).blocksProtectedContent,
      isTrue,
    );
  });

  test('configured lock blocks only blocking phases', () {
    const AppLockPreference configured = AppLockPreference(
      method: AppLockMethod.biometric,
      timeout: AppLockTimeout.immediately,
    );
    expect(
      const AppLockState(
        phase: AppLockPhase.locked,
        preference: configured,
      ).blocksProtectedContent,
      isTrue,
    );
    expect(
      const AppLockState(
        phase: AppLockPhase.unlocked,
        preference: configured,
      ).blocksProtectedContent,
      isFalse,
    );
  });
}
