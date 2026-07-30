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

class _SessionProbe {
  const _SessionProbe._({
    this.authData,
    required this.invalid,
    required this.transient,
  });

  const _SessionProbe.valid(Map<String, dynamic> authData)
    : this._(authData: authData, invalid: false, transient: false);

  const _SessionProbe.invalid() : this._(invalid: true, transient: false);

  const _SessionProbe.transient() : this._(invalid: false, transient: true);

  final Map<String, dynamic>? authData;
  final bool invalid;
  final bool transient;

  bool get isValid => authData != null && !invalid && !transient;
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

  Future<bool>? _refreshingSession;
  Future<Either<Failure, void>>? _loginInFlight;
  StreamSubscription<void>? _sessionSub;

  bool _isHydrating = false;
  DateTime? _lastRefresh;
  static const _refreshCooldown = Duration(seconds: 5);

  // ---------------------------------------------------------------------------
  // INIT (FSM: Loading → Guest / Authenticated)
  // ---------------------------------------------------------------------------
  Future<void> init() async {
    try {
      _sessionSub ??= _apiClient.sessionExpiredStream.listen((_) async {
        if (state is! AuthAuthenticated) return;

        if (_isHydrating) {
          appLogger.w('[Auth] Ignored session expiry during hydration');
          return;
        }

        if (_refreshingSession != null) return;

        _refreshingSession = _refreshSession();

        final refreshed = await _refreshingSession!;
        _refreshingSession = null;

        if (!refreshed) {
          appLogger.w('[Auth] Session expired → guest');
          await _clearSession();
        }
      });

      final sid = await _storage.getSid();

      if (sid == null || sid.isEmpty) {
        await _ref
            .read(userPreferenceControllerProvider.notifier)
            .restoreGuestSnapshot();
        state = const AuthGuest();
        return;
      }

      final probe = await _fetchValidSession(sid);

      if (probe.isValid) {
        await _completeLogin(sid: sid, authData: probe.authData!);
        return;
      }

      if (probe.invalid) {
        await _clearSession();
        return;
      }

      appLogger.w('[Auth] Session validation temporarily failed');
      state = const AuthGuest();
    } catch (e) {
      appLogger.e('[Auth] init error: $e');
      await _clearSession();
    }
  }

  // ---------------------------------------------------------------------------
  // SESSION VALIDATION
  // ---------------------------------------------------------------------------
  Future<_SessionProbe> _fetchValidSession(String sid) async {
    try {
      await _apiClient.setSid(sid);

      final res = await _api.me();

      if (res.isLeft) {
        final failure = res.leftOrNull;

        if (_isInvalidSessionFailure(failure)) {
          return const _SessionProbe.invalid();
        }

        return const _SessionProbe.transient();
      }

      final payload = res.rightOrNull ?? {};
      if (payload['ok'] != true) {
        final failure = _failureFromPayload(
          payload,
          fallbackMessage: 'Session invalid. Please login again.',
        );
        return _isInvalidSessionFailure(failure)
            ? const _SessionProbe.invalid()
            : const _SessionProbe.transient();
      }

      final data = asJsonMap(payload['data']);
      final user = asJsonMap(data['user']);

      if (user.isEmpty) return const _SessionProbe.invalid();

      return _SessionProbe.valid(data);
    } catch (e) {
      appLogger.e('[Auth] Fetch session error: $e');
      return const _SessionProbe.transient();
    }
  }

  // ---------------------------------------------------------------------------
  // SESSION REFRESH
  // ---------------------------------------------------------------------------
  Future<bool> _refreshSession() async {
    final DateTime now = _now();

    if (_lastRefresh != null &&
        now.difference(_lastRefresh!) < _refreshCooldown) {
      appLogger.w('[Auth] Refresh skipped (cooldown)');
      return true;
    }

    _lastRefresh = now;

    final sid = await _storage.getSid();

    if (sid == null || sid.isEmpty) {
      appLogger.w('[Auth] No SID during refresh');
      return false;
    }

    final probe = await _fetchValidSession(sid);

    if (probe.transient) {
      appLogger.w('[Auth] Refresh temporarily failed; keeping session');
      return true;
    }

    if (!probe.isValid) {
      appLogger.w('[Auth] Refresh failed (invalid session)');
      return false;
    }

    await _completeLogin(sid: sid, authData: probe.authData!);

    appLogger.i('[Auth] Session refreshed');

    return true;
  }

  // ---------------------------------------------------------------------------
  // LOGIN (FSM: Guest → Authenticated)
  // ---------------------------------------------------------------------------
  Future<Either<Failure, void>> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) {
    final Future<Either<Failure, void>>? activeRequest = _loginInFlight;
    if (activeRequest != null) return activeRequest;

    late final Future<Either<Failure, void>> request;
    request =
        _performLogin(
          identifier: identifier,
          password: password,
          rememberMe: rememberMe,
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
  }) async {
    final String cleanIdentifier = identifier.trim().toLowerCase();

    await _storage.clearSid();
    await _apiClient.clearSid();

    final res = await _api.login(
      identifier: cleanIdentifier,
      password: password,
    );
    final finished = await _finishAuthResponse(
      res,
      fallbackMessage: 'Login failed.',
    );

    if (finished.isLeft) return finished;

    await _storage.setRememberMe(rememberMe);
    if (rememberMe) {
      await _storage.setRememberedEmail(cleanIdentifier);
    } else {
      await _storage.clearRememberedEmail();
    }

    return Either.right(null);
  }

  // ---------------------------------------------------------------------------
  // LOGOUT (FSM: Authenticated → Guest)
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Logout is idempotent server-side. Local cleanup must always happen.
    }

    await _clearSession();
  }

  Future<void> _clearSession() async {
    await _storage.clearSid();
    await _apiClient.clearSid();

    _refreshingSession = null;
    _isHydrating = false;

    await _ref
        .read(userPreferenceControllerProvider.notifier)
        .restoreGuestSnapshot();
    state = const AuthGuest();
  }

  // ---------------------------------------------------------------------------
  // COMPLETE LOGIN / HYDRATION (single source of truth)
  // ---------------------------------------------------------------------------
  Future<void> _completeLogin({
    required String sid,
    required Map<String, dynamic> authData,
  }) async {
    _isHydrating = true;

    try {
      await _apiClient.setSid(sid);
      await _storage.setSid(sid);

      final synchronizedPreferences = await _syncUserPreferencesAfterLogin(
        authData,
      );
      if (synchronizedPreferences == null) {
        throw StateError(
          'Authenticated account preferences could not be synchronized.',
        );
      }

      final user = asJsonMap(authData['user']);
      final preferences = synchronizedPreferences;
      final seller = AuthSellerSummary.fromMap(asJsonMap(authData['seller']));
      final roles = asJsonList(authData['roles'])
          .map((role) => role.toString())
          .where((role) => role.trim().isNotEmpty)
          .toList(growable: false);

      state = AuthAuthenticated(
        user: AuthUser.fromMap(user),
        sid: sid,
        preferences: preferences,
        roles: roles,
        seller: seller,
      );
    } finally {
      _isHydrating = false;
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE UPDATE (Authenticated → Authenticated)
  // ---------------------------------------------------------------------------
  void setUserFromMap(Map<String, dynamic> userMap) {
    if (state is! AuthAuthenticated) return;

    final current = state as AuthAuthenticated;

    state = current.copyWith(user: AuthUser.fromMap(userMap));
  }

  void setPreferencesFromMap(Map<String, dynamic> preferencesMap) {
    if (state is! AuthAuthenticated) return;
    if (preferencesMap.isEmpty) return;

    final current = state as AuthAuthenticated;

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
    try {
      final idToken = await GoogleAuthService.signInAndGetIdToken();

      if (idToken == null || idToken.isEmpty) {
        return Either.left(const Failure('Google sign-in cancelled.'));
      }

      await _storage.clearSid();
      await _apiClient.clearSid();

      final res = await _api.googleLogin(
        idToken: idToken,
        country: country ?? '',
        language: language ?? '',
        currency: currency ?? '',
      );

      return _finishAuthResponse(res, fallbackMessage: 'Google login failed.');
    } catch (e) {
      appLogger.e('[Auth] Google sign-in failed: $e');
      return Either.left(
        const Failure('Google sign-in failed. Please try again.'),
      );
    }
  }

  Future<Either<Failure, void>> signInWithApple({
    String? country,
    String? language,
    String? currency,
  }) async {
    try {
      final credential = await AppleAuthService().signIn();
      final idToken = credential?.identityToken;

      if (idToken == null || idToken.isEmpty) {
        return Either.left(const Failure('Apple sign-in cancelled.'));
      }

      await _storage.clearSid();
      await _apiClient.clearSid();

      final res = await _api.appleLogin(
        idToken: idToken,
        country: country ?? '',
        language: language ?? '',
        currency: currency ?? '',
      );

      return _finishAuthResponse(res, fallbackMessage: 'Apple login failed.');
    } catch (e) {
      appLogger.e('[Auth] Apple sign-in failed: $e');
      return Either.left(
        const Failure('Apple sign-in failed. Please try again.'),
      );
    }
  }

  Future<Either<Failure, void>> _finishAuthResponse(
    Either<Failure, Map<String, dynamic>> response, {
    required String fallbackMessage,
  }) async {
    if (response.isLeft) {
      return Either.left(
        _normalizeFailure(response.leftOrNull, fallbackMessage),
      );
    }

    final payload = response.rightOrNull ?? {};
    if (payload['ok'] != true) {
      return Either.left(
        _failureFromPayload(payload, fallbackMessage: fallbackMessage),
      );
    }

    final data = asJsonMap(payload['data']);
    final session = asJsonMap(data['session']);
    if (session['authenticated'] != true) {
      return Either.left(
        const Failure('Login failed. Session is not authenticated.'),
      );
    }

    final sid = asString(session['sid']).trim();
    if (sid.isEmpty) {
      return Either.left(
        const Failure('Login failed. No session was returned.'),
      );
    }

    final user = asJsonMap(data['user']);
    if (user.isEmpty) {
      return Either.left(const Failure('Login failed. User data was missing.'));
    }

    try {
      await _completeLogin(sid: sid, authData: data);
    } catch (error) {
      appLogger.e('[Auth] Login hydration failed: $error');
      await _clearSession();
      return Either.left(
        const Failure(
          'Login succeeded, but account preferences could not be restored.',
        ),
      );
    }

    return Either.right(null);
  }

  Failure _failureFromPayload(
    Map<String, dynamic> payload, {
    required String fallbackMessage,
  }) {
    return Failure.fromServerPayload(payload, fallbackMessage: fallbackMessage);
  }

  Failure _normalizeFailure(Failure? failure, String fallbackMessage) {
    if (failure == null) return Failure(fallbackMessage);

    final error = (failure.error ?? '').trim().toUpperCase();
    if (error.isEmpty) return failure;

    return failure.copyWith(
      message: authFriendlyMessage(error, fallback: failure.message),
      type: failureTypeForAuthError(error, statusCode: failure.statusCode),
      error: error,
    );
  }

  bool _isInvalidSessionFailure(Failure? failure) {
    final error = (failure?.error ?? '').trim().toUpperCase();

    return (failure?.isAuthRequired ?? false) ||
        failure?.statusCode == 401 ||
        error == 'ACCOUNT_DISABLED' ||
        error == 'ACCOUNT_DELETED' ||
        error == 'ACCOUNT_DELETED_RESTORABLE' ||
        error == 'ACCOUNT_SUSPENDED';
  }

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
    unawaited(_sessionSub?.cancel());
    _refreshingSession = null;
    super.dispose();
  }
}
