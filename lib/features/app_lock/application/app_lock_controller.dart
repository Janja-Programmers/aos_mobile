import 'dart:async';

import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/app_lock/data/app_lock_preference_repository.dart';
import 'package:africaonlinestores/features/app_lock/data/app_lock_secret_hasher.dart';
import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:africaonlinestores/features/app_lock/platform/native_app_lock_service.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

abstract interface class MonotonicClock {
  Duration get elapsed;
}

class StopwatchMonotonicClock implements MonotonicClock {
  StopwatchMonotonicClock() : _stopwatch = Stopwatch()..start();

  final Stopwatch _stopwatch;

  @override
  Duration get elapsed => _stopwatch.elapsed;
}

class AppLockController extends StateNotifier<AppLockState> {
  AppLockController({
    required AppLockPreferenceRepository repository,
    required AppLockSecretHasher secretHasher,
    required NativeAppLockService nativeService,
    required MonotonicClock clock,
  }) : _repository = repository,
       _secretHasher = secretHasher,
       _nativeService = nativeService,
       _clock = clock,
       super(AppLockState.initial);

  static const int pinLength = 4;
  static const int minimumPatternPoints = 4;

  final AppLockPreferenceRepository _repository;
  final AppLockSecretHasher _secretHasher;
  final NativeAppLockService _nativeService;
  final MonotonicClock _clock;

  Duration? _hiddenAt;
  Future<AppLockResult>? _biometricInFlight;
  Future<AppLockResult>? _secretVerificationInFlight;
  int _generation = 0;
  bool _nativePromptActive = false;
  int _failedSecretAttempts = 0;
  Duration? _secretBlockedUntil;

  bool get nativePromptActive => _nativePromptActive;

  Future<void> handleAuthState(AuthState authState) async {
    final String? nextAccount = authState is AuthAuthenticated
        ? authState.user.email.trim().toLowerCase()
        : null;

    if (nextAccount == null || nextAccount.isEmpty) {
      ++_generation;
      state = AppLockState.initial.copyWith(
        phase: AppLockPhase.disabled,
        clearAccountId: true,
      );
      _resetSecretAttemptState();
      await _cancelVerification();
      return;
    }

    if (state.accountId == nextAccount &&
        state.phase != AppLockPhase.initializing &&
        state.phase != AppLockPhase.unavailable) {
      return;
    }

    final int generation = ++_generation;
    final bool accountChanged =
        state.accountId != null && state.accountId != nextAccount;
    state = AppLockState.initial.copyWith(accountId: nextAccount);
    _resetSecretAttemptState();

    if (accountChanged) {
      await _cancelVerification();
      if (!_isCurrent(generation, nextAccount)) return;
    }

    try {
      final AppLockPreference preference = await _repository.read(nextAccount);
      if (!_isCurrent(generation, nextAccount)) return;

      state = AppLockState(
        phase: preference.enabled ? AppLockPhase.locked : AppLockPhase.disabled,
        preference: preference,
        accountId: nextAccount,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        '[AppLock] Failed to read app-lock configuration',
        error: error,
        stackTrace: stackTrace,
      );
      if (!_isCurrent(generation, nextAccount)) return;
      state = AppLockState(
        phase: AppLockPhase.unavailable,
        preference: AppLockPreference.disabled,
        error: AppLockError.storageFailure,
        accountId: nextAccount,
      );
    }
  }

  void handleLifecycle(AppLifecycleSnapshot lifecycle) {
    if (!state.isEnabled || state.accountId == null) return;

    if (lifecycle.shouldProtectContent) {
      _hiddenAt ??= _clock.elapsed;
      if (!_nativePromptActive &&
          state.preference.timeout == AppLockTimeout.immediately) {
        _lock();
      }
      return;
    }

    if (lifecycle.phase != AppVisibilityPhase.foreground) return;
    final Duration? hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (_nativePromptActive || hiddenAt == null) return;

    final Duration elapsed = _clock.elapsed - hiddenAt;
    if (elapsed >= state.preference.timeout.duration) {
      _lock();
    }
  }

  Future<AppLockResult> configurePin(String pin) async {
    if (!_isValidPin(pin)) {
      return const AppLockResult(AppLockError.invalidPin);
    }
    return _configureSecret(method: AppLockMethod.pin, secret: pin);
  }

  Future<AppLockResult> configurePattern(List<int> pattern) async {
    final List<int>? normalized = normalizePattern(pattern);
    if (normalized == null) {
      return const AppLockResult(AppLockError.patternTooShort);
    }
    return _configureSecret(
      method: AppLockMethod.pattern,
      secret: normalized.join('-'),
    );
  }

  Future<AppLockResult> configureBiometric({required String reason}) async {
    final String? accountId = state.accountId;
    final int generation = _generation;
    if (accountId == null) {
      return const AppLockResult(AppLockError.unsupported);
    }

    final AppLockResult availability = await _nativeService
        .checkBiometricAvailability();
    if (!_isCurrent(generation, accountId)) {
      return const AppLockResult(AppLockError.systemCancelled);
    }
    if (!availability.isSuccess) {
      state = state.copyWith(error: availability.error);
      return availability;
    }

    final AppLockResult result = await _authenticateBiometric(reason: reason);
    if (!result.isSuccess || !_isCurrent(generation, accountId)) return result;

    final AppLockPreference preference = AppLockPreference(
      method: AppLockMethod.biometric,
      timeout: state.preference.timeout,
    );
    return _persistConfiguredPreference(
      accountId: accountId,
      generation: generation,
      preference: preference,
    );
  }

  Future<AppLockResult> unlockWithPin(String pin) {
    if (state.preference.method != AppLockMethod.pin) {
      return Future<AppLockResult>.value(
        const AppLockResult(AppLockError.invalidCredential),
      );
    }
    return _verifySecret(secret: pin, unlockOnSuccess: true);
  }

  Future<AppLockResult> unlockWithPattern(List<int> pattern) {
    final List<int>? normalized = normalizePattern(pattern);
    if (state.preference.method != AppLockMethod.pattern ||
        normalized == null) {
      return Future<AppLockResult>.value(
        const AppLockResult(AppLockError.invalidCredential),
      );
    }
    return _verifySecret(secret: normalized.join('-'), unlockOnSuccess: true);
  }

  Future<AppLockResult> unlockWithBiometric({required String reason}) async {
    if (state.preference.method != AppLockMethod.biometric) {
      return const AppLockResult(AppLockError.invalidCredential);
    }
    final int generation = _generation;
    final String? accountId = state.accountId;
    final AppLockResult result = await _authenticateBiometric(reason: reason);
    if (result.isSuccess &&
        accountId != null &&
        _isCurrent(generation, accountId) &&
        state.isEnabled) {
      state = state.copyWith(phase: AppLockPhase.unlocked, clearError: true);
    }
    return result;
  }

  Future<AppLockResult> verifyPin(String pin) {
    if (state.preference.method != AppLockMethod.pin) {
      return Future<AppLockResult>.value(
        const AppLockResult(AppLockError.invalidCredential),
      );
    }
    return _verifySecret(secret: pin, unlockOnSuccess: false);
  }

  Future<AppLockResult> verifyPattern(List<int> pattern) {
    final List<int>? normalized = normalizePattern(pattern);
    if (state.preference.method != AppLockMethod.pattern ||
        normalized == null) {
      return Future<AppLockResult>.value(
        const AppLockResult(AppLockError.invalidCredential),
      );
    }
    return _verifySecret(secret: normalized.join('-'), unlockOnSuccess: false);
  }

  Future<AppLockResult> verifyBiometric({required String reason}) {
    if (state.preference.method != AppLockMethod.biometric) {
      return Future<AppLockResult>.value(
        const AppLockResult(AppLockError.invalidCredential),
      );
    }
    return _authenticateBiometric(reason: reason);
  }

  Future<AppLockResult> disableWithPin(String pin) async {
    final AppLockResult verified = await verifyPin(pin);
    return verified.isSuccess ? _disableAfterVerification() : verified;
  }

  Future<AppLockResult> disableWithPattern(List<int> pattern) async {
    final AppLockResult verified = await verifyPattern(pattern);
    return verified.isSuccess ? _disableAfterVerification() : verified;
  }

  Future<AppLockResult> disableWithBiometric({required String reason}) async {
    final AppLockResult verified = await verifyBiometric(reason: reason);
    return verified.isSuccess ? _disableAfterVerification() : verified;
  }

  Future<void> setTimeout(AppLockTimeout timeout) async {
    final String? accountId = state.accountId;
    if (accountId == null || !state.preference.enabled) return;

    final AppLockPreference previousPreference = state.preference;
    final AppLockPreference preference = previousPreference.copyWith(
      timeout: timeout,
    );
    state = state.copyWith(preference: preference);
    try {
      await _repository.write(accountId, preference);
    } catch (error, stackTrace) {
      appLogger.e(
        '[AppLock] Failed to persist timeout',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        preference: previousPreference,
        error: AppLockError.storageFailure,
      );
    }
  }

  /// Recovery path used only when the user explicitly resets a forgotten lock.
  Future<void> resetForLogout() async {
    final String? accountId = state.accountId;
    ++_generation;
    state = AppLockState.initial.copyWith(
      phase: AppLockPhase.disabled,
      clearAccountId: true,
    );
    _resetSecretAttemptState();
    await _cancelVerification();
    if (accountId != null) {
      try {
        await _repository.clear(accountId);
      } catch (error, stackTrace) {
        appLogger.e(
          '[AppLock] Failed to clear app-lock configuration during reset',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  static List<int>? normalizePattern(List<int> pattern) {
    final List<int> normalized = <int>[];
    for (final int point in pattern) {
      if (point < 0 || point > 8 || normalized.contains(point)) continue;
      normalized.add(point);
    }
    return normalized.length >= minimumPatternPoints ? normalized : null;
  }

  static bool _isValidPin(String pin) =>
      RegExp(r'^\d{4}$').hasMatch(pin) && pin.length == pinLength;

  Future<AppLockResult> _configureSecret({
    required AppLockMethod method,
    required String secret,
  }) async {
    final String? accountId = state.accountId;
    final int generation = _generation;
    if (accountId == null) {
      return const AppLockResult(AppLockError.unsupported);
    }

    state = state.copyWith(phase: AppLockPhase.verifying, clearError: true);
    try {
      final AppLockSecretDigest digest = await _secretHasher.create(secret);
      if (!_isCurrent(generation, accountId)) {
        return const AppLockResult(AppLockError.systemCancelled);
      }
      final AppLockPreference preference = AppLockPreference(
        method: method,
        timeout: state.preference.timeout,
        secretHash: digest.hash,
        salt: digest.salt,
        hashIterations: digest.iterations,
      );
      return _persistConfiguredPreference(
        accountId: accountId,
        generation: generation,
        preference: preference,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        '[AppLock] Failed to configure local credential',
        error: error,
        stackTrace: stackTrace,
      );
      if (_isCurrent(generation, accountId)) {
        state = state.copyWith(
          phase: state.isEnabled
              ? AppLockPhase.unlocked
              : AppLockPhase.disabled,
          error: AppLockError.storageFailure,
        );
      }
      return const AppLockResult(AppLockError.storageFailure);
    }
  }

  Future<AppLockResult> _persistConfiguredPreference({
    required String accountId,
    required int generation,
    required AppLockPreference preference,
  }) async {
    try {
      await _repository.write(accountId, preference);
      if (!_isCurrent(generation, accountId)) {
        return const AppLockResult(AppLockError.systemCancelled);
      }
      state = AppLockState(
        phase: AppLockPhase.unlocked,
        preference: preference,
        accountId: accountId,
      );
      return const AppLockResult.success();
    } catch (error, stackTrace) {
      appLogger.e(
        '[AppLock] Failed to persist app-lock configuration',
        error: error,
        stackTrace: stackTrace,
      );
      if (_isCurrent(generation, accountId)) {
        state = state.copyWith(
          phase: state.isEnabled
              ? AppLockPhase.unlocked
              : AppLockPhase.disabled,
          error: AppLockError.storageFailure,
        );
      }
      return const AppLockResult(AppLockError.storageFailure);
    }
  }

  Future<AppLockResult> _verifySecret({
    required String secret,
    required bool unlockOnSuccess,
  }) {
    final Duration? blockedUntil = _secretBlockedUntil;
    if (blockedUntil != null && _clock.elapsed < blockedUntil) {
      state = state.copyWith(error: AppLockError.temporaryLockout);
      return Future<AppLockResult>.value(
        const AppLockResult(AppLockError.temporaryLockout),
      );
    }
    if (blockedUntil != null) _resetSecretAttemptState();

    final Future<AppLockResult>? existing = _secretVerificationInFlight;
    if (existing != null) return existing;

    final String? accountId = state.accountId;
    final int generation = _generation;
    final AppLockPreference preference = state.preference;
    if (accountId == null ||
        preference.secretHash == null ||
        preference.salt == null) {
      return Future<AppLockResult>.value(
        const AppLockResult(AppLockError.invalidCredential),
      );
    }

    final AppLockPhase previousPhase = state.phase;
    state = state.copyWith(phase: AppLockPhase.verifying, clearError: true);

    late final Future<AppLockResult> request;
    request = _secretHasher
        .verify(
          secret: secret,
          expectedHash: preference.secretHash!,
          salt: preference.salt!,
          iterations: preference.hashIterations,
        )
        .then((bool valid) {
          if (!_isCurrent(generation, accountId)) {
            return const AppLockResult(AppLockError.systemCancelled);
          }
          if (!valid) {
            _failedSecretAttempts++;
            final bool temporarilyBlocked = _failedSecretAttempts >= 5;
            if (temporarilyBlocked) {
              _secretBlockedUntil =
                  _clock.elapsed + const Duration(seconds: 30);
            }
            final AppLockError error = temporarilyBlocked
                ? AppLockError.temporaryLockout
                : AppLockError.invalidCredential;
            state = state.copyWith(
              phase: previousPhase == AppLockPhase.locked
                  ? AppLockPhase.locked
                  : AppLockPhase.unlocked,
              error: error,
            );
            return AppLockResult(error);
          }
          _resetSecretAttemptState();
          state = state.copyWith(
            phase: unlockOnSuccess
                ? AppLockPhase.unlocked
                : (previousPhase == AppLockPhase.locked
                      ? AppLockPhase.locked
                      : AppLockPhase.unlocked),
            clearError: true,
          );
          return const AppLockResult.success();
        })
        .catchError((Object error, StackTrace stackTrace) {
          appLogger.e(
            '[AppLock] Local credential verification failed',
            error: error,
            stackTrace: stackTrace,
          );
          if (_isCurrent(generation, accountId)) {
            state = state.copyWith(
              phase: previousPhase == AppLockPhase.locked
                  ? AppLockPhase.locked
                  : AppLockPhase.unlocked,
              error: AppLockError.unknown,
            );
          }
          return const AppLockResult(AppLockError.unknown);
        })
        .whenComplete(() {
          if (identical(_secretVerificationInFlight, request)) {
            _secretVerificationInFlight = null;
          }
        });
    _secretVerificationInFlight = request;
    return request;
  }

  Future<AppLockResult> _authenticateBiometric({required String reason}) {
    final Future<AppLockResult>? existing = _biometricInFlight;
    if (existing != null) return existing;

    final int generation = _generation;
    final String? accountId = state.accountId;
    final AppLockPhase previousPhase = state.phase;
    _nativePromptActive = true;
    state = state.copyWith(phase: AppLockPhase.verifying, clearError: true);

    late final Future<AppLockResult> request;
    request = _nativeService
        .authenticateBiometric(reason: reason)
        .then((AppLockResult result) {
          if (_isCurrent(generation, accountId)) {
            if (!result.isSuccess) {
              state = state.copyWith(
                phase: previousPhase == AppLockPhase.locked
                    ? AppLockPhase.locked
                    : (state.isEnabled
                          ? AppLockPhase.unlocked
                          : AppLockPhase.disabled),
                error: result.error,
              );
            } else if (previousPhase != AppLockPhase.locked) {
              state = state.copyWith(
                phase: state.isEnabled
                    ? AppLockPhase.unlocked
                    : AppLockPhase.disabled,
                clearError: true,
              );
            }
          }
          return result;
        })
        .whenComplete(() {
          if (identical(_biometricInFlight, request)) {
            _biometricInFlight = null;
            _nativePromptActive = false;
            _hiddenAt = null;
          }
        });
    _biometricInFlight = request;
    return request;
  }

  Future<AppLockResult> _disableAfterVerification() async {
    final String? accountId = state.accountId;
    final int generation = _generation;
    if (accountId == null) {
      return const AppLockResult(AppLockError.unsupported);
    }

    try {
      await _repository.clear(accountId);
      if (!_isCurrent(generation, accountId)) {
        return const AppLockResult(AppLockError.systemCancelled);
      }
      state = AppLockState(
        phase: AppLockPhase.disabled,
        preference: AppLockPreference.disabled,
        accountId: accountId,
      );
      return const AppLockResult.success();
    } catch (error, stackTrace) {
      appLogger.e(
        '[AppLock] Failed to disable app lock',
        error: error,
        stackTrace: stackTrace,
      );
      if (_isCurrent(generation, accountId)) {
        state = state.copyWith(
          phase: AppLockPhase.unlocked,
          error: AppLockError.storageFailure,
        );
      }
      return const AppLockResult(AppLockError.storageFailure);
    }
  }

  Future<void> _cancelVerification() async {
    _hiddenAt = null;
    _secretVerificationInFlight = null;
    _biometricInFlight = null;
    _nativePromptActive = false;
    try {
      await _nativeService.cancel();
    } catch (error, stackTrace) {
      appLogger.w(
        '[AppLock] Native authentication cancellation failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _resetSecretAttemptState() {
    _failedSecretAttempts = 0;
    _secretBlockedUntil = null;
  }

  bool _isCurrent(int generation, String? accountId) =>
      generation == _generation && state.accountId == accountId;

  void _lock() {
    if (!state.isEnabled || state.phase == AppLockPhase.locked) return;
    state = state.copyWith(phase: AppLockPhase.locked, clearError: true);
  }
}

final appLockPreferenceRepositoryProvider =
    Provider<AppLockPreferenceRepository>(
      (ref) => const SecureAppLockPreferenceRepository(),
    );
final appLockSecretHasherProvider = Provider<AppLockSecretHasher>(
  (ref) => const Pbkdf2AppLockSecretHasher(),
);
final nativeAppLockServiceProvider = Provider<NativeAppLockService>(
  (ref) => LocalAuthAppLockService(),
);
final appLockMonotonicClockProvider = Provider<MonotonicClock>(
  (ref) => StopwatchMonotonicClock(),
);

final appLockControllerProvider =
    StateNotifierProvider<AppLockController, AppLockState>((ref) {
      final AppLockController controller = AppLockController(
        repository: ref.watch(appLockPreferenceRepositoryProvider),
        secretHasher: ref.watch(appLockSecretHasherProvider),
        nativeService: ref.watch(nativeAppLockServiceProvider),
        clock: ref.watch(appLockMonotonicClockProvider),
      );

      ref.listen<AuthState>(authControllerProvider, (_, AuthState next) {
        unawaited(controller.handleAuthState(next));
      }, fireImmediately: true);
      ref.listen<AppLifecycleSnapshot>(appLifecycleControllerProvider, (
        _,
        AppLifecycleSnapshot next,
      ) {
        controller.handleLifecycle(next);
      }, fireImmediately: true);
      return controller;
    });

final appLockAccessPermittedProvider = Provider<bool>((ref) {
  final AuthState auth = ref.watch(authControllerProvider);
  final AppLockState lock = ref.watch(appLockControllerProvider);
  return auth is AuthAuthenticated && !lock.blocksProtectedContent;
});
