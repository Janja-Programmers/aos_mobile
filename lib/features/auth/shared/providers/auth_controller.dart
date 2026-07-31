import 'dart:async';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/api/session_storage.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/auth/data/apple_auth_service.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/data/google_auth_service.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/data/preferences_api_provider.dart';
import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum _SessionProbeStatus { valid, invalid, transient }

class _SessionProbe {
  const _SessionProbe._({required this.status, this.authData, this.failure});

  const _SessionProbe.valid(Map<String, dynamic> authData)
    : this._(status: _SessionProbeStatus.valid, authData: authData);

  const _SessionProbe.invalid(Failure failure)
    : this._(status: _SessionProbeStatus.invalid, failure: failure);

  const _SessionProbe.transient([Failure? failure])
    : this._(status: _SessionProbeStatus.transient, failure: failure);

  final _SessionProbeStatus status;
  final Map<String, dynamic>? authData;
  final Failure? failure;

  bool get isValid => status == _SessionProbeStatus.valid;
  bool get isInvalid => status == _SessionProbeStatus.invalid;
  bool get isTransient => status == _SessionProbeStatus.transient;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required Ref ref,
    required AuthApi api,
    required ApiClient apiClient,
    required SessionStorage storage,
    DateTime Function()? now,
  }) : _ref = ref,
       _api = api,
       _apiClient = apiClient,
       _storage = storage,
       _now = now ?? DateTime.now,
       super(const AuthLoading());

  final Ref _ref;
  final AuthApi _api;
  final ApiClient _apiClient;
  final SessionStorage _storage;
  final DateTime Function() _now;

  Future<void>? _initializationInFlight;
  Future<bool>? _refreshingSession;
  Future<Either<Failure, void>>? _loginInFlight;
  StreamSubscription<void>? _sessionSub;

  bool _isHydrating = false;
  DateTime? _lastRefresh;
  int _operationGeneration = 0;

  static const _refreshCooldown = Duration(seconds: 5);

  // ---------------------------------------------------------------------------
  // INIT (FSM: Loading/Failure -> Restoring -> Guest/Authenticated/Failure)
  // ---------------------------------------------------------------------------
  Future<void> init() {
    if (state is AuthGuest || state is AuthAuthenticated) {
      return Future<void>.value();
    }

    final Future<void>? activeRequest = _initializationInFlight;
    if (activeRequest != null) return activeRequest;

    final int generation = ++_operationGeneration;
    late final Future<void> request;
    request = _initialize(generation).whenComplete(() {
      if (identical(_initializationInFlight, request)) {
        _initializationInFlight = null;
      }
    });
    _initializationInFlight = request;
    return request;
  }

  Future<void> retrySessionRestoration() async {
    if (state is! AuthRestorationFailure) return;

    final Future<void>? activeRequest = _initializationInFlight;
    if (activeRequest != null) {
      await activeRequest;
    }
    if (state is AuthRestorationFailure) {
      await init();
    }
  }

  Future<void> _initialize(int generation) async {
    _ensureSessionListener();

    try {
      final String? sid = await _storage.getSid();
      if (!_isCurrent(generation)) return;

      if (sid == null || sid.isEmpty) {
        await _ref
            .read(userPreferenceControllerProvider.notifier)
            .restoreGuestSnapshot();
        if (!_isCurrent(generation)) return;
        state = const AuthGuest();
        return;
      }

      state = const AuthRestoring();
      final _SessionProbe probe = await _fetchValidSession(sid);
      if (!_isCurrent(generation)) return;

      if (probe.isValid) {
        await _completeLogin(
          sid: sid,
          authData: probe.authData!,
          generation: generation,
          persistSid: false,
        );
        return;
      }

      if (probe.isInvalid) {
        await _clearSession(expectedGeneration: generation);
        return;
      }

      appLogger.w('[Auth] Session validation temporarily unavailable');
      state = AuthRestorationFailure(
        reason: _restorationFailureReason(probe.failure),
      );
    } catch (error, stackTrace) {
      if (!_isCurrent(generation)) return;
      appLogger.e(
        '[Auth] Session restoration failed temporarily',
        error: error,
        stackTrace: stackTrace,
      );
      state = const AuthRestorationFailure(
        reason: AuthRestorationFailureReason.unknown,
      );
    }
  }

  void _ensureSessionListener() {
    _sessionSub ??= _apiClient.sessionExpiredStream.listen((_) {
      unawaited(_handleSessionExpired());
    });
  }

  Future<void> _handleSessionExpired() async {
    if (state is! AuthAuthenticated || _isHydrating) return;

    final Future<bool>? activeRefresh = _refreshingSession;
    if (activeRefresh != null) {
      await activeRefresh;
      return;
    }

    final int generation = _operationGeneration;
    late final Future<bool> request;
    request = _refreshSession(generation).whenComplete(() {
      if (identical(_refreshingSession, request)) {
        _refreshingSession = null;
      }
    });
    _refreshingSession = request;

    final bool refreshed = await request;
    if (!refreshed && _isCurrent(generation)) {
      appLogger.w('[Auth] Backend confirmed session expiry');
      await _clearSession(expectedGeneration: generation);
    }
  }

  // ---------------------------------------------------------------------------
  // SESSION VALIDATION
  // ---------------------------------------------------------------------------
  Future<_SessionProbe> _fetchValidSession(String sid) async {
    try {
      await _apiClient.setSid(sid);

      final Either<Failure, Map<String, dynamic>> response = await _api.me();

      if (response.isLeft) {
        final Failure? failure = response.leftOrNull;
        if (_isInvalidSessionFailure(failure)) {
          return _SessionProbe.invalid(failure!);
        }
        return _SessionProbe.transient(failure);
      }

      final Map<String, dynamic> payload =
          response.rightOrNull ?? <String, dynamic>{};
      if (payload['ok'] != true) {
        final Failure failure = _failureFromPayload(
          payload,
          fallbackMessage: 'Session could not be restored.',
        );
        return _isInvalidSessionFailure(failure)
            ? _SessionProbe.invalid(failure)
            : _SessionProbe.transient(failure);
      }

      final Map<String, dynamic> data = asJsonMap(payload['data']);
      final Map<String, dynamic> user = asJsonMap(data['user']);
      if (user.isEmpty) {
        return const _SessionProbe.transient(
          Failure('Session response was incomplete.', type: FailureType.parse),
        );
      }

      return _SessionProbe.valid(data);
    } catch (error, stackTrace) {
      appLogger.e(
        '[Auth] Session probe failed',
        error: error,
        stackTrace: stackTrace,
      );
      return const _SessionProbe.transient(
        Failure('Session validation failed.', type: FailureType.unknown),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SESSION REFRESH
  // ---------------------------------------------------------------------------
  Future<bool> _refreshSession(int generation) async {
    final DateTime now = _now();

    if (_lastRefresh != null &&
        now.difference(_lastRefresh!) < _refreshCooldown) {
      appLogger.w('[Auth] Refresh skipped during cooldown');
      return true;
    }

    _lastRefresh = now;

    final String? sid = await _storage.getSid();
    if (!_isCurrent(generation)) return true;

    if (sid == null || sid.isEmpty) {
      appLogger.w('[Auth] No stored session during refresh');
      return false;
    }

    final _SessionProbe probe = await _fetchValidSession(sid);
    if (!_isCurrent(generation)) return true;

    if (probe.isTransient) {
      appLogger.w('[Auth] Refresh temporarily unavailable; session preserved');
      return true;
    }

    if (!probe.isValid) {
      return false;
    }

    await _completeLogin(
      sid: sid,
      authData: probe.authData!,
      generation: generation,
      persistSid: false,
    );

    if (_isCurrent(generation)) {
      appLogger.i('[Auth] Session refreshed');
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // LOGIN (FSM: Guest -> Authenticated)
  // ---------------------------------------------------------------------------
  Future<Either<Failure, void>> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) {
    final Future<Either<Failure, void>>? activeRequest = _loginInFlight;
    if (activeRequest != null) return activeRequest;

    final int generation = ++_operationGeneration;
    late final Future<Either<Failure, void>> request;
    request =
        _performLogin(
          identifier: identifier,
          password: password,
          rememberMe: rememberMe,
          generation: generation,
        ).whenComplete(() {
          if (identical(_loginInFlight, request)) {
            _loginInFlight = null;
          }
        });
    _loginInFlight = request;
    return request;
  }

  Future<Either<Failure, void>> _performLogin({
    required String identifier,
    required String password,
    required bool rememberMe,
    required int generation,
  }) async {
    final String cleanIdentifier = identifier.trim().toLowerCase();

    await _storage.clearSid();
    await _apiClient.clearSid();
    if (!_isCurrent(generation)) {
      return Either<Failure, void>.left(const Failure('Login was superseded.'));
    }

    final Either<Failure, Map<String, dynamic>> response = await _api.login(
      identifier: cleanIdentifier,
      password: password,
    );
    if (!_isCurrent(generation)) {
      return Either<Failure, void>.left(const Failure('Login was superseded.'));
    }

    final Either<Failure, void> finished = await _finishAuthResponse(
      response,
      fallbackMessage: 'Login failed.',
      generation: generation,
    );

    if (finished.isLeft || !_isCurrent(generation)) return finished;

    await _storage.setRememberMe(rememberMe);
    if (!_isCurrent(generation)) return finished;

    if (rememberMe) {
      await _storage.setRememberedEmail(cleanIdentifier);
    } else {
      await _storage.clearRememberedEmail();
    }

    return finished;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT (Authenticated/Failure -> Guest)
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    final int generation = ++_operationGeneration;
    _initializationInFlight = null;
    _loginInFlight = null;
    _refreshingSession = null;

    try {
      await _api.logout();
    } catch (_) {
      // Backend logout is idempotent. Local cleanup is authoritative here.
    }

    await _clearSession(expectedGeneration: generation);
  }

  Future<void> _clearSession({int? expectedGeneration}) async {
    if (expectedGeneration != null && !_isCurrent(expectedGeneration)) return;

    await _storage.clearSid();
    if (expectedGeneration != null && !_isCurrent(expectedGeneration)) return;

    await _apiClient.clearSid();
    if (expectedGeneration != null && !_isCurrent(expectedGeneration)) return;

    _refreshingSession = null;
    _isHydrating = false;
    _lastRefresh = null;

    try {
      await _ref
          .read(userPreferenceControllerProvider.notifier)
          .restoreGuestSnapshot();
    } catch (error, stackTrace) {
      appLogger.w(
        '[Auth] Guest preference restoration failed during local cleanup',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (expectedGeneration != null && !_isCurrent(expectedGeneration)) return;

    state = const AuthGuest();
  }

  // ---------------------------------------------------------------------------
  // COMPLETE LOGIN / HYDRATION (single source of truth)
  // ---------------------------------------------------------------------------
  Future<bool> _completeLogin({
    required String sid,
    required Map<String, dynamic> authData,
    required int generation,
    required bool persistSid,
  }) async {
    if (!_isCurrent(generation)) return false;
    _isHydrating = true;

    try {
      await _apiClient.setSid(sid);
      if (!_isCurrent(generation)) return false;

      final Map<String, dynamic>? synchronizedPreferences =
          await _syncUserPreferencesAfterLogin(authData);
      if (!_isCurrent(generation)) return false;
      if (synchronizedPreferences == null) {
        throw StateError(
          'Authenticated account preferences could not be synchronized.',
        );
      }

      if (persistSid) {
        await _storage.setSid(sid);
        if (!_isCurrent(generation)) return false;
      }

      final Map<String, dynamic> user = asJsonMap(authData['user']);
      final AuthSellerSummary seller = AuthSellerSummary.fromMap(
        asJsonMap(authData['seller']),
      );
      final List<String> roles = asJsonList(authData['roles'])
          .map((Object? role) => role?.toString() ?? '')
          .where((String role) => role.trim().isNotEmpty)
          .toList(growable: false);

      state = AuthAuthenticated(
        user: AuthUser.fromMap(user),
        sid: sid,
        preferences: synchronizedPreferences,
        roles: roles,
        seller: seller,
      );
      return true;
    } finally {
      _isHydrating = false;
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE UPDATE (Authenticated -> Authenticated)
  // ---------------------------------------------------------------------------
  void setUserFromMap(Map<String, dynamic> userMap) {
    if (state is! AuthAuthenticated) return;

    final AuthAuthenticated current = state as AuthAuthenticated;
    state = current.copyWith(user: AuthUser.fromMap(userMap));
  }

  void setPreferencesFromMap(Map<String, dynamic> preferencesMap) {
    if (state is! AuthAuthenticated || preferencesMap.isEmpty) return;

    final AuthAuthenticated current = state as AuthAuthenticated;
    state = current.copyWith(
      preferences: <String, dynamic>{...current.preferences, ...preferencesMap},
    );
  }

  // ---------------------------------------------------------------------------
  // SOCIAL LOGINS
  // ---------------------------------------------------------------------------
  Future<Either<Failure, void>> signInWithGoogle({
    String? country,
    String? language,
    String? currency,
  }) async {
    final int generation = ++_operationGeneration;

    try {
      final String? idToken = await GoogleAuthService.signInAndGetIdToken();
      if (!_isCurrent(generation)) {
        return Either<Failure, void>.left(
          const Failure('Google sign-in was superseded.'),
        );
      }

      if (idToken == null || idToken.isEmpty) {
        return Either<Failure, void>.left(
          const Failure('Google sign-in cancelled.'),
        );
      }

      await _storage.clearSid();
      await _apiClient.clearSid();
      if (!_isCurrent(generation)) {
        return Either<Failure, void>.left(
          const Failure('Google sign-in was superseded.'),
        );
      }

      final Either<Failure, Map<String, dynamic>> response = await _api
          .googleLogin(
            idToken: idToken,
            country: country ?? '',
            language: language ?? '',
            currency: currency ?? '',
          );

      return _finishAuthResponse(
        response,
        fallbackMessage: 'Google login failed.',
        generation: generation,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        '[Auth] Google sign-in failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either<Failure, void>.left(
        const Failure('Google sign-in failed. Please try again.'),
      );
    }
  }

  Future<Either<Failure, void>> signInWithApple({
    String? country,
    String? language,
    String? currency,
  }) async {
    final int generation = ++_operationGeneration;

    try {
      final credential = await AppleAuthService().signIn();
      final String? idToken = credential?.identityToken;
      if (!_isCurrent(generation)) {
        return Either<Failure, void>.left(
          const Failure('Apple sign-in was superseded.'),
        );
      }

      if (idToken == null || idToken.isEmpty) {
        return Either<Failure, void>.left(
          const Failure('Apple sign-in cancelled.'),
        );
      }

      await _storage.clearSid();
      await _apiClient.clearSid();
      if (!_isCurrent(generation)) {
        return Either<Failure, void>.left(
          const Failure('Apple sign-in was superseded.'),
        );
      }

      final Either<Failure, Map<String, dynamic>> response = await _api
          .appleLogin(
            idToken: idToken,
            country: country ?? '',
            language: language ?? '',
            currency: currency ?? '',
          );

      return _finishAuthResponse(
        response,
        fallbackMessage: 'Apple login failed.',
        generation: generation,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        '[Auth] Apple sign-in failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Either<Failure, void>.left(
        const Failure('Apple sign-in failed. Please try again.'),
      );
    }
  }

  Future<Either<Failure, void>> _finishAuthResponse(
    Either<Failure, Map<String, dynamic>> response, {
    required String fallbackMessage,
    required int generation,
  }) async {
    if (!_isCurrent(generation)) {
      return Either<Failure, void>.left(
        const Failure('Authentication was superseded.'),
      );
    }

    if (response.isLeft) {
      return Either<Failure, void>.left(
        _normalizeFailure(response.leftOrNull, fallbackMessage),
      );
    }

    final Map<String, dynamic> payload =
        response.rightOrNull ?? <String, dynamic>{};
    if (payload['ok'] != true) {
      return Either<Failure, void>.left(
        _failureFromPayload(payload, fallbackMessage: fallbackMessage),
      );
    }

    final Map<String, dynamic> data = asJsonMap(payload['data']);
    final Map<String, dynamic> session = asJsonMap(data['session']);
    if (session['authenticated'] != true) {
      return Either<Failure, void>.left(
        const Failure('Login failed. Session is not authenticated.'),
      );
    }

    final String sid = asString(session['sid']).trim();
    if (sid.isEmpty) {
      return Either<Failure, void>.left(
        const Failure('Login failed. No session was returned.'),
      );
    }

    final Map<String, dynamic> user = asJsonMap(data['user']);
    if (user.isEmpty) {
      return Either<Failure, void>.left(
        const Failure('Login failed. User data was missing.'),
      );
    }

    try {
      final bool completed = await _completeLogin(
        sid: sid,
        authData: data,
        generation: generation,
        persistSid: true,
      );
      if (!completed) {
        return Either<Failure, void>.left(
          const Failure('Authentication was superseded.'),
        );
      }
    } catch (error, stackTrace) {
      appLogger.e(
        '[Auth] Login hydration failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _clearSession(expectedGeneration: generation);
      return Either<Failure, void>.left(
        const Failure(
          'Login succeeded, but account preferences could not be restored.',
        ),
      );
    }

    return Either<Failure, void>.right(null);
  }

  Failure _failureFromPayload(
    Map<String, dynamic> payload, {
    required String fallbackMessage,
  }) {
    return Failure.fromServerPayload(payload, fallbackMessage: fallbackMessage);
  }

  Failure _normalizeFailure(Failure? failure, String fallbackMessage) {
    if (failure == null) return Failure(fallbackMessage);

    final String error = (failure.error ?? '').trim().toUpperCase();
    if (error.isEmpty) return failure;

    return failure.copyWith(
      message: authFriendlyMessage(error, fallback: failure.message),
      type: failureTypeForAuthError(error, statusCode: failure.statusCode),
      error: error,
    );
  }

  bool _isInvalidSessionFailure(Failure? failure) {
    final String error = (failure?.error ?? '').trim().toUpperCase();

    return error == 'AUTH_REQUIRED' ||
        error == 'SESSION_INVALID' ||
        error == 'UNAUTHORIZED' ||
        error == 'UNAUTHENTICATED' ||
        error == 'LOGIN_REQUIRED' ||
        error == 'ACCOUNT_DISABLED' ||
        error == 'ACCOUNT_DELETED' ||
        error == 'ACCOUNT_DELETED_RESTORABLE' ||
        error == 'ACCOUNT_SUSPENDED';
  }

  AuthRestorationFailureReason _restorationFailureReason(Failure? failure) {
    switch (failure?.type) {
      case FailureType.network:
        return AuthRestorationFailureReason.network;
      case FailureType.timeout:
        return AuthRestorationFailureReason.timeout;
      case FailureType.server:
      case FailureType.rateLimited:
        return AuthRestorationFailureReason.server;
      case FailureType.unauthorized:
      case FailureType.forbidden:
      case FailureType.notFound:
      case FailureType.validation:
      case FailureType.parse:
      case FailureType.unknown:
      case null:
        return AuthRestorationFailureReason.unknown;
    }
  }

  bool _isCurrent(int generation) => generation == _operationGeneration;

  // ---------------------------------------------------------------------------
  // USER PREFERENCES SYNC
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> _syncUserPreferencesAfterLogin(
    Map<String, dynamic> authData,
  ) async {
    final preferencesFromAuth = await _syncUserPreferencesFromAuthData(
      authData,
    );
    if (preferencesFromAuth != null) return preferencesFromAuth;
    return _syncUserPreferences();
  }

  Future<Map<String, dynamic>?> _syncUserPreferencesFromAuthData(
    Map<String, dynamic> authData,
  ) async {
    final preferences = asJsonMap(authData['preferences']);
    if (preferences.isEmpty) return null;

    try {
      await _ref
          .read(userPreferenceControllerProvider.notifier)
          .syncFromServerPreferences(
            preferences,
            authority: PreferenceAuthority.authenticatedLogin,
          );
      return preferences;
    } catch (error) {
      appLogger.e('[Auth] Prefs sync from auth payload failed: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _syncUserPreferences() async {
    final prefApi = _ref.read(userPreferenceApiProvider);
    final prefCtrl = _ref.read(userPreferenceControllerProvider.notifier);

    const maxAttempts = 2;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        appLogger.i('[Auth] Sync prefs attempt $attempt');
        final result = await prefApi.getMyPreferences();
        if (result.isLeft) {
          appLogger.w('[Auth] Prefs fetch failed (attempt $attempt)');
          continue;
        }

        final payload = result.rightOrNull ?? <String, dynamic>{};
        if (payload['ok'] != true) {
          appLogger.w('[Auth] Prefs invalid payload');
          continue;
        }

        final data = asJsonMap(payload['data']);
        if (data.isEmpty) continue;

        await prefCtrl.syncFromServerPreferences(
          data,
          authority: PreferenceAuthority.authenticatedMe,
        );
        return data;
      } catch (error) {
        appLogger.e('[Auth] Prefs sync error (attempt $attempt): $error');
        if (attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
    }
    return null;
  }

  Future<Either<Failure, String>> register({
    required String email,
    required String password,
    required String fullName,
    String? country,
    String? language,
    String? currency,
  }) async {
    final res = await _api.register(
      email: email,
      password: password,
      fullName: fullName,
      country: country ?? '',
      language: language ?? '',
      currency: currency ?? '',
    );
    if (res.isLeft) {
      return Either.left(
        _normalizeFailure(res.leftOrNull, 'Registration failed.'),
      );
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'Success' : 'Failed')).toString();
    return ok
        ? Either.right(msg)
        : Either.left(_failureFromPayload(payload, fallbackMessage: msg));
  }

  // OTP
  Future<Either<Failure, String>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _api.verifyOtp(email: email, otp: otp);
    if (res.isLeft) {
      return Either.left(
        _normalizeFailure(res.leftOrNull, 'Verification failed.'),
      );
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg =
        (payload['message'] ?? (ok ? 'Verified' : 'Verification failed'))
            .toString();
    return ok
        ? Either.right(msg)
        : Either.left(_failureFromPayload(payload, fallbackMessage: msg));
  }

  Future<Either<Failure, String>> resendOtp({required String email}) async {
    final res = await _api.resendOtp(email: email);
    if (res.isLeft) {
      return Either.left(
        _normalizeFailure(res.leftOrNull, 'Failed to resend code.'),
      );
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? 'Sent').toString();
    return ok
        ? Either.right(msg)
        : Either.left(_failureFromPayload(payload, fallbackMessage: msg));
  }

  // Forgot password
  Future<Either<Failure, String>> forgotPasswordRequest({
    required String email,
  }) async {
    final res = await _api.forgotPasswordRequest(email: email);
    if (res.isLeft) {
      return Either.left(
        _normalizeFailure(res.leftOrNull, 'Failed to request OTP.'),
      );
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'OTP sent' : 'Failed')).toString();
    return ok
        ? Either.right(msg)
        : Either.left(_failureFromPayload(payload, fallbackMessage: msg));
  }

  Future<Either<Failure, String>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _api.forgotPasswordVerifyOtp(email: email, otp: otp);
    if (res.isLeft) {
      return Either.left(
        _normalizeFailure(res.leftOrNull, 'Verification failed.'),
      );
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      final msg = (payload['message'] ?? 'Verification failed').toString();
      return Either.left(_failureFromPayload(payload, fallbackMessage: msg));
    }

    final data = asJsonMap(payload['data']);
    final token = (data['reset_token'] ?? '').toString();
    if (token.isEmpty) {
      return Either.left(
        const Failure('Verification succeeded but no reset token returned.'),
      );
    }
    return Either.right(token);
  }

  Future<Either<Failure, String>> forgotPasswordReset({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await _api.forgotPasswordReset(
      email: email,
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (res.isLeft) {
      return Either.left(
        _normalizeFailure(res.leftOrNull, 'Password update failed.'),
      );
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'Password updated' : 'Failed'))
        .toString();
    return ok
        ? Either.right(msg)
        : Either.left(_failureFromPayload(payload, fallbackMessage: msg));
  }

  // Change password (logged-in)
  Future<Either<Failure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (res.isLeft) {
      return Either.left(
        _normalizeFailure(res.leftOrNull, 'Password change failed.'),
      );
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'Password changed' : 'Failed'))
        .toString();
    return ok
        ? Either.right(msg)
        : Either.left(_failureFromPayload(payload, fallbackMessage: msg));
  }

  Future<(bool remember, String email)> getRememberedLogin() async {
    final remember = await _storage.getRememberMe();
    final email = await _storage.getRememberedEmail();
    return (remember, remember ? email : '');
  }

  // ---------------------------------------------------------------------------
  // CLEANUP
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    ++_operationGeneration;
    unawaited(_sessionSub?.cancel());
    _initializationInFlight = null;
    _refreshingSession = null;
    _loginInFlight = null;
    super.dispose();
  }
}
