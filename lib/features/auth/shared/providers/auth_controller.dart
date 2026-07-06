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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class _SessionProbe {
  const _SessionProbe._({
    this.user,
    required this.invalid,
    required this.transient,
  });

  const _SessionProbe.valid(Map<String, dynamic> user)
    : this._(user: user, invalid: false, transient: false);

  const _SessionProbe.invalid() : this._(invalid: true, transient: false);

  const _SessionProbe.transient() : this._(invalid: false, transient: true);

  final Map<String, dynamic>? user;
  final bool invalid;
  final bool transient;

  bool get isValid => user != null && !invalid && !transient;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required Ref ref,
    required AuthApi api,
    required ApiClient apiClient,
    required SessionStorage storage,
  }) : _ref = ref,
       _api = api,
       _apiClient = apiClient,
       _storage = storage,
       super(const AuthLoading());

  final Ref _ref;
  final AuthApi _api;
  final ApiClient _apiClient;
  final SessionStorage _storage;

  Future<bool>? _refreshingSession;
  StreamSubscription<void>? _sessionSub;

  bool _isHydrating = false;
  DateTime? _lastRefresh;
  static const _refreshCooldown = Duration(seconds: 5);

  // ---------------------------------------------------------------------------
  // INIT (FSM: Loading → Guest / Authenticated)
  // ---------------------------------------------------------------------------
  Future<void> init() async {
    try {
      // Listen for session expiry (401)

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
        state = const AuthGuest();
        return;
      }

      final probe = await _fetchValidSession(sid);

      if (probe.isValid) {
        await _completeLogin(sid: sid, user: probe.user!);
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

        if (failure?.type == FailureType.unauthorized ||
            failure?.statusCode == 401) {
          return const _SessionProbe.invalid();
        }

        return const _SessionProbe.transient();
      }

      final payload = res.rightOrNull ?? {};
      if (payload['ok'] != true) return const _SessionProbe.invalid();

      final data = asJsonMap(payload['data']);
      final user = asJsonMap(data['user']);

      if (user.isEmpty) return const _SessionProbe.invalid();

      return _SessionProbe.valid(user);
    } catch (e) {
      appLogger.e('[Auth] Fetch session error: $e');
      return const _SessionProbe.transient();
    }
  }

  // ---------------------------------------------------------------------------
  // SESSION REFRESH
  // ---------------------------------------------------------------------------
  Future<bool> _refreshSession() async {
    final now = DateTime.now();

    /// ✅ debounce refresh
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

    state = AuthAuthenticated(user: AuthUser.fromMap(probe.user!), sid: sid);

    /// ✅ DO NOT BLOCK AUTH
    unawaited(_syncUserPreferences());

    appLogger.i('[Auth] Session refreshed');

    return true;
  }

  // ---------------------------------------------------------------------------
  // LOGIN (FSM: Guest → Authenticated)
  // ---------------------------------------------------------------------------
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final res = await _api.login(email: email, password: password);

    if (res.isLeft) {
      return Either.left(res.leftOrNull ?? const Failure('Login failed.'));
    }

    final payload = res.rightOrNull ?? {};
    if (payload['ok'] != true) {
      return Either.left(
        Failure(payload['message']?.toString() ?? 'Login failed.'),
      );
    }

    final data = asJsonMap(payload['data'] ?? {});
    final sid = data['sid']?.toString() ?? '';

    if (sid.isEmpty) {
      return Either.left(const Failure('Login failed (no session).'));
    }

    await _completeLogin(sid: sid, user: asJsonMap(data['user'] ?? {}));

    return Either.right(null);
  }

  // ---------------------------------------------------------------------------
  // LOGOUT (FSM: Authenticated → Guest)
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}

    await _clearSession();
  }

  Future<void> _clearSession() async {
    await _storage.clearSid();
    await _apiClient.clearSid();

    _refreshingSession = null;

    state = const AuthGuest();
  }

  // ---------------------------------------------------------------------------
  // COMPLETE LOGIN (single source of truth)
  // ---------------------------------------------------------------------------
  Future<void> _completeLogin({
    required String sid,
    required Map<String, dynamic> user,
  }) async {
    _isHydrating = true;

    await _apiClient.setSid(sid);
    await _storage.setSid(sid);

    state = AuthAuthenticated(user: AuthUser.fromMap(user), sid: sid);

    /// ✅ run in background
    unawaited(_syncUserPreferences());

    _isHydrating = false;
  }

  // ---------------------------------------------------------------------------
  // PROFILE UPDATE (Authenticated → Authenticated)
  // ---------------------------------------------------------------------------
  void setUserFromMap(Map<String, dynamic> userMap) {
    if (state is! AuthAuthenticated) return;

    final current = state as AuthAuthenticated;

    state = current.copyWith(user: AuthUser.fromMap(userMap));
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

      final res = await _api.googleLogin(
        idToken: idToken,
        country: country ?? '',
        language: language ?? '',
        currency: currency ?? '',
      );

      if (res.isLeft) return Either.left(res.leftOrNull!);

      final payload = res.rightOrNull ?? {};
      if (payload['ok'] != true) {
        return Either.left(
          Failure((payload['message'] ?? 'Google login failed').toString()),
        );
      }

      final data = asJsonMap(payload['data'] ?? {});
      final sid = (data['sid'] ?? '').toString();

      if (sid.isEmpty) {
        return Either.left(const Failure('No session returned.'));
      }

      await _completeLogin(sid: sid, user: asJsonMap(data['user'] ?? {}));

      return Either.right(null);
    } catch (e) {
      return Either.left(Failure('Google sign-in failed: $e'));
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

      final res = await _api.appleLogin(
        idToken: idToken,
        country: country ?? '',
        language: language ?? '',
        currency: currency ?? '',
      );

      if (res.isLeft) return Either.left(res.leftOrNull!);

      final payload = res.rightOrNull ?? {};
      if (payload['ok'] != true) {
        return Either.left(
          Failure((payload['message'] ?? 'Apple login failed').toString()),
        );
      }

      final data = asJsonMap(payload['data'] ?? {});
      final sid = (data['sid'] ?? '').toString();

      if (sid.isEmpty) {
        return Either.left(const Failure('No session returned.'));
      }

      await _completeLogin(sid: sid, user: asJsonMap(data['user'] ?? {}));

      return Either.right(null);
    } catch (e) {
      return Either.left(Failure('Apple sign-in failed: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // USER PREFERENCES SYNC
  // ---------------------------------------------------------------------------
  Future<void> _syncUserPreferences() async {
    final prefApi = _ref.read(userPreferenceApiProvider);
    final prefCtrl = _ref.read(userPreferenceControllerProvider.notifier);

    const maxAttempts = 2;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        appLogger.i('[Auth] Sync prefs attempt $attempt');

        final res = await prefApi.getMyPreferences();

        if (res.isLeft) {
          appLogger.w('[Auth] Prefs fetch failed (attempt $attempt)');
          continue;
        }

        final payload = res.rightOrNull ?? {};
        if (payload['ok'] != true) {
          appLogger.w('[Auth] Prefs invalid payload');
          return;
        }

        final data = asJsonMap(payload['data'] ?? {});

        final country = asJsonMap(data['country']);
        final language = asJsonMap(data['language']);
        final currency = asJsonMap(data['currency']);

        await prefCtrl.syncFromServer(
          countryCode: asString(country['code']),
          languageCode: asString(language['code']),
          currencyCode: asString(currency['name']),
        );

        return;
      } catch (e) {
        appLogger.e('[Auth] Prefs sync error (attempt $attempt): $e');

        if (attempt == maxAttempts) return;

        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
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
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'Success' : 'Failed')).toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
  }

  // OTP
  Future<Either<Failure, String>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _api.verifyOtp(email: email, otp: otp);
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg =
        (payload['message'] ?? (ok ? 'Verified' : 'Verification failed'))
            .toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
  }

  Future<Either<Failure, String>> resendOtp({required String email}) async {
    final res = await _api.resendOtp(email: email);
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? 'Sent').toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
  }

  // Forgot password
  Future<Either<Failure, String>> forgotPasswordRequest({
    required String email,
  }) async {
    final res = await _api.forgotPasswordRequest(email: email);
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'OTP sent' : 'Failed')).toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
  }

  Future<Either<Failure, String>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _api.forgotPasswordVerifyOtp(email: email, otp: otp);
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      final msg = (payload['message'] ?? 'Verification failed').toString();
      return Either.left(Failure(msg));
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
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'Password updated' : 'Failed'))
        .toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
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
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'Password changed' : 'Failed'))
        .toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
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
