enum AppLockPhase {
  disabled,
  initializing,
  locked,
  verifying,
  unlocked,
  unavailable,
}

enum AppLockMethod { pin, pattern, biometric }

enum AppLockTimeout {
  immediately(Duration.zero),
  fiveSeconds(Duration(seconds: 5)),
  tenSeconds(Duration(seconds: 10)),
  fifteenSeconds(Duration(seconds: 15)),
  thirtySeconds(Duration(seconds: 30));

  const AppLockTimeout(this.duration);

  final Duration duration;

  String get storageValue => name;

  static AppLockTimeout fromStorage(String? value) {
    if (value == 'oneMinute' || value == 'fiveMinutes') {
      return AppLockTimeout.thirtySeconds;
    }
    return AppLockTimeout.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppLockTimeout.immediately,
    );
  }
}

enum AppLockError {
  success,
  userCancelled,
  systemCancelled,
  authenticationFailed,
  invalidCredential,
  temporaryLockout,
  permanentLockout,
  notEnrolled,
  noDeviceCredential,
  hardwareUnavailable,
  hardwareTemporarilyUnavailable,
  backgroundInterrupted,
  alreadyInProgress,
  unsupported,
  invalidPin,
  patternTooShort,
  confirmationMismatch,
  storageFailure,
  unknown,
}

class AppLockResult {
  const AppLockResult(this.error);
  const AppLockResult.success() : error = AppLockError.success;

  final AppLockError error;

  bool get isSuccess => error == AppLockError.success;
}

class AppLockPreference {
  const AppLockPreference({
    required this.method,
    required this.timeout,
    this.secretHash,
    this.salt,
    this.hashIterations = 120000,
    this.version = 2,
  });

  final AppLockMethod? method;
  final AppLockTimeout timeout;
  final String? secretHash;
  final String? salt;
  final int hashIterations;
  final int version;

  static const AppLockPreference disabled = AppLockPreference(
    method: null,
    timeout: AppLockTimeout.immediately,
  );

  bool get enabled => method != null;
  bool get usesSecret =>
      method == AppLockMethod.pin || method == AppLockMethod.pattern;
  bool get hasUsableSecret =>
      !usesSecret ||
      ((secretHash?.isNotEmpty ?? false) && (salt?.isNotEmpty ?? false));

  AppLockPreference copyWith({
    AppLockMethod? method,
    bool clearMethod = false,
    AppLockTimeout? timeout,
    String? secretHash,
    bool clearSecretHash = false,
    String? salt,
    bool clearSalt = false,
    int? hashIterations,
    int? version,
  }) {
    return AppLockPreference(
      method: clearMethod ? null : (method ?? this.method),
      timeout: timeout ?? this.timeout,
      secretHash: clearSecretHash ? null : (secretHash ?? this.secretHash),
      salt: clearSalt ? null : (salt ?? this.salt),
      hashIterations: hashIterations ?? this.hashIterations,
      version: version ?? this.version,
    );
  }
}

class AppLockState {
  const AppLockState({
    required this.phase,
    required this.preference,
    this.error,
    this.accountId,
  });

  final AppLockPhase phase;
  final AppLockPreference preference;
  final AppLockError? error;
  final String? accountId;

  static const initial = AppLockState(
    phase: AppLockPhase.initializing,
    preference: AppLockPreference.disabled,
  );

  bool get blocksProtectedContent =>
      (accountId != null &&
          (phase == AppLockPhase.initializing ||
              phase == AppLockPhase.unavailable)) ||
      (preference.enabled &&
          (phase == AppLockPhase.locked || phase == AppLockPhase.verifying));

  bool get isEnabled => preference.enabled;

  AppLockState copyWith({
    AppLockPhase? phase,
    AppLockPreference? preference,
    AppLockError? error,
    bool clearError = false,
    String? accountId,
    bool clearAccountId = false,
  }) {
    return AppLockState(
      phase: phase ?? this.phase,
      preference: preference ?? this.preference,
      error: clearError ? null : (error ?? this.error),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
    );
  }
}
