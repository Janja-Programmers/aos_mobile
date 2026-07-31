import 'dart:async';

import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:africaonlinestores/features/app_lock/application/app_lock_controller.dart';
import 'package:africaonlinestores/features/app_lock/data/app_lock_preference_repository.dart';
import 'package:africaonlinestores/features/app_lock/data/app_lock_secret_hasher.dart';
import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:africaonlinestores/features/app_lock/platform/native_app_lock_service.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeRepository repository;
  late _FakeHasher hasher;
  late _FakeNativeService nativeService;
  late _FakeClock clock;
  late AppLockController controller;

  setUp(() {
    repository = _FakeRepository();
    hasher = _FakeHasher();
    nativeService = _FakeNativeService();
    clock = _FakeClock();
    controller = AppLockController(
      repository: repository,
      secretHasher: hasher,
      nativeService: nativeService,
      clock: clock,
    );
  });

  test('new install has no app lock', () async {
    await controller.handleAuthState(_authenticated('one@example.com'));

    expect(controller.state.phase, AppLockPhase.disabled);
    expect(controller.state.preference.enabled, isFalse);
  });

  test('storage read failure blocks private content and can retry', () async {
    repository.readError = StateError('storage unavailable') as Exception?;

    await controller.handleAuthState(_authenticated('one@example.com'));

    expect(controller.state.phase, AppLockPhase.unavailable);
    expect(controller.state.blocksProtectedContent, isTrue);

    repository
      ..readError = null
      ..value = _pinPreference();
    await controller.handleAuthState(_authenticated('one@example.com'));

    expect(controller.state.phase, AppLockPhase.locked);
  });

  test('process initialization locks a configured account', () async {
    repository.value = _pinPreference(timeout: AppLockTimeout.tenSeconds);

    await controller.handleAuthState(_authenticated('one@example.com'));

    expect(controller.state.phase, AppLockPhase.locked);
    expect(controller.state.preference.method, AppLockMethod.pin);
  });

  test('PIN must be exactly four digits and is stored as a digest', () async {
    await controller.handleAuthState(_authenticated('one@example.com'));

    expect(
      (await controller.configurePin('123')).error,
      AppLockError.invalidPin,
    );
    expect(repository.writes, 0);

    final AppLockResult result = await controller.configurePin('1234');

    expect(result.isSuccess, isTrue);
    expect(repository.value.method, AppLockMethod.pin);
    expect(repository.value.secretHash, 'hash:1234');
    expect(repository.value.secretHash, isNot('1234'));
    expect(controller.state.phase, AppLockPhase.unlocked);
  });

  test('pattern requires four unique valid points', () async {
    await controller.handleAuthState(_authenticated('one@example.com'));

    expect(
      (await controller.configurePattern(<int>[0, 1, 2])).error,
      AppLockError.patternTooShort,
    );

    final AppLockResult result = await controller.configurePattern(<int>[
      0,
      1,
      4,
      8,
    ]);

    expect(result.isSuccess, isTrue);
    expect(repository.value.method, AppLockMethod.pattern);
    expect(repository.value.secretHash, 'hash:0-1-4-8');
  });

  test(
    'biometric setup persists only after successful biometric auth',
    () async {
      await controller.handleAuthState(_authenticated('one@example.com'));
      nativeService.authenticateResult = const AppLockResult(
        AppLockError.userCancelled,
      );

      final AppLockResult cancelled = await controller.configureBiometric(
        reason: 'Enable',
      );
      expect(cancelled.error, AppLockError.userCancelled);
      expect(repository.writes, 0);

      nativeService.authenticateResult = const AppLockResult.success();
      final AppLockResult enabled = await controller.configureBiometric(
        reason: 'Enable',
      );
      expect(enabled.isSuccess, isTrue);
      expect(repository.value.method, AppLockMethod.biometric);
    },
  );

  test('PIN unlock accepts only the configured secret', () async {
    repository.value = _pinPreference();
    await controller.handleAuthState(_authenticated('one@example.com'));

    hasher.validSecret = '1234';
    expect(
      (await controller.unlockWithPin('0000')).error,
      AppLockError.invalidCredential,
    );
    expect(controller.state.phase, AppLockPhase.locked);

    expect((await controller.unlockWithPin('1234')).isSuccess, isTrue);
    expect(controller.state.phase, AppLockPhase.unlocked);
  });

  test('five failed PIN attempts trigger a temporary local cooldown', () async {
    repository.value = _pinPreference();
    await controller.handleAuthState(_authenticated('one@example.com'));
    hasher.validSecret = '1234';

    for (int attempt = 0; attempt < 4; attempt++) {
      expect(
        (await controller.unlockWithPin('0000')).error,
        AppLockError.invalidCredential,
      );
    }
    expect(
      (await controller.unlockWithPin('0000')).error,
      AppLockError.temporaryLockout,
    );
    expect(
      (await controller.unlockWithPin('1234')).error,
      AppLockError.temporaryLockout,
    );

    clock.value = const Duration(seconds: 31);
    expect((await controller.unlockWithPin('1234')).isSuccess, isTrue);
  });

  test('duplicate biometric taps share one native prompt', () async {
    repository.value = const AppLockPreference(
      method: AppLockMethod.biometric,
      timeout: AppLockTimeout.immediately,
    );
    await controller.handleAuthState(_authenticated('one@example.com'));
    nativeService.pending = Completer<AppLockResult>();

    final Future<AppLockResult> first = controller.unlockWithBiometric(
      reason: 'Unlock',
    );
    final Future<AppLockResult> second = controller.unlockWithBiometric(
      reason: 'Unlock',
    );

    expect(nativeService.authenticateCalls, 1);
    nativeService.pending!.complete(const AppLockResult.success());
    expect((await first).isSuccess, isTrue);
    expect((await second).isSuccess, isTrue);
    expect(controller.state.phase, AppLockPhase.unlocked);
  });

  test('stale biometric result cannot unlock a different account', () async {
    repository.value = const AppLockPreference(
      method: AppLockMethod.biometric,
      timeout: AppLockTimeout.immediately,
    );
    await controller.handleAuthState(_authenticated('one@example.com'));
    nativeService.pending = Completer<AppLockResult>();
    final Future<AppLockResult> unlock = controller.unlockWithBiometric(
      reason: 'Unlock',
    );

    await controller.handleAuthState(_authenticated('two@example.com'));
    nativeService.pending!.complete(const AppLockResult.success());
    await unlock;

    expect(controller.state.accountId, 'two@example.com');
    expect(controller.state.phase, AppLockPhase.locked);
    expect(nativeService.cancelCalls, 1);
  });

  test(
    'normal logout clears runtime state without deleting configuration',
    () async {
      repository.value = _pinPreference();
      await controller.handleAuthState(_authenticated('one@example.com'));

      await controller.handleAuthState(const AuthGuest());

      expect(controller.state.phase, AppLockPhase.disabled);
      expect(repository.clears, 0);
    },
  );

  test(
    'explicit reset clears configuration for forgotten-lock recovery',
    () async {
      repository.value = _pinPreference();
      await controller.handleAuthState(_authenticated('one@example.com'));

      await controller.resetForLogout();

      expect(repository.clears, 1);
      expect(controller.state.phase, AppLockPhase.disabled);
      expect(controller.state.accountId, isNull);
    },
  );

  test('monotonic timeout locks only after selected duration', () async {
    repository.value = _pinPreference(timeout: AppLockTimeout.tenSeconds);
    await controller.handleAuthState(_authenticated('one@example.com'));
    hasher.validSecret = '1234';
    await controller.unlockWithPin('1234');

    controller.handleLifecycle(_snapshot(AppVisibilityPhase.hidden, 1));
    clock.value = const Duration(seconds: 9);
    controller.handleLifecycle(_snapshot(AppVisibilityPhase.foreground, 2));
    expect(controller.state.phase, AppLockPhase.unlocked);

    controller.handleLifecycle(_snapshot(AppVisibilityPhase.hidden, 3));
    clock.value = const Duration(seconds: 20);
    controller.handleLifecycle(_snapshot(AppVisibilityPhase.foreground, 4));
    expect(controller.state.phase, AppLockPhase.locked);
  });
}

AppLockPreference _pinPreference({
  AppLockTimeout timeout = AppLockTimeout.immediately,
}) {
  return AppLockPreference(
    method: AppLockMethod.pin,
    timeout: timeout,
    secretHash: 'hash:1234',
    salt: 'salt',
    hashIterations: 1,
  );
}

AuthAuthenticated _authenticated(String email) => AuthAuthenticated(
  user: AuthUser(email: email, fullName: 'User'),
  sid: 'sid',
);

AppLifecycleSnapshot _snapshot(AppVisibilityPhase phase, int sequence) {
  return AppLifecycleSnapshot(
    phase: phase,
    sequence: sequence,
    isInitial: false,
  );
}

class _FakeRepository implements AppLockPreferenceRepository {
  AppLockPreference value = AppLockPreference.disabled;
  int writes = 0;
  int clears = 0;
  Exception? readError;

  @override
  Future<void> clear(String accountId) async {
    clears++;
    value = AppLockPreference.disabled;
  }

  @override
  Future<AppLockPreference> read(String accountId) async {
    final Exception? error = readError;
    if (error != null) throw error;
    return value;
  }

  @override
  Future<void> write(String accountId, AppLockPreference preference) async {
    writes++;
    value = preference;
  }
}

class _FakeHasher implements AppLockSecretHasher {
  String validSecret = '1234';

  @override
  Future<AppLockSecretDigest> create(String secret) async {
    return AppLockSecretDigest(
      hash: 'hash:$secret',
      salt: 'salt',
      iterations: 1,
    );
  }

  @override
  Future<bool> verify({
    required String secret,
    required String expectedHash,
    required String salt,
    required int iterations,
  }) async {
    return secret == validSecret && expectedHash == 'hash:$validSecret';
  }
}

class _FakeNativeService implements NativeAppLockService {
  AppLockResult availability = const AppLockResult.success();
  AppLockResult authenticateResult = const AppLockResult.success();
  Completer<AppLockResult>? pending;
  int authenticateCalls = 0;
  int cancelCalls = 0;

  @override
  Future<AppLockResult> authenticateBiometric({required String reason}) {
    authenticateCalls++;
    return pending?.future ?? Future<AppLockResult>.value(authenticateResult);
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }

  @override
  Future<AppLockResult> checkBiometricAvailability() async => availability;
}

class _FakeClock implements MonotonicClock {
  Duration value = Duration.zero;

  @override
  Duration get elapsed => value;
}
