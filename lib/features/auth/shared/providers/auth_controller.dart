import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/session_storage.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/auth/data/auth_api_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/data/google_auth_service.dart';
import 'package:africaonlinestores/features/auth/data/apple_auth_service.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/data/preferences_api_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final api = ref.watch(authApiProvider);
    final client = ref.watch(apiClientProvider);
    final storage = ref.watch(sessionStorageProvider);
    return AuthController(
      ref: ref,
      api: api,
      apiClient: client,
      storage: storage,
    )..init();
  },
);

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
       super(AuthState.initial());

  final Ref _ref;
  final AuthApi _api;
  final ApiClient _apiClient;
  final SessionStorage _storage;
  bool _isLoggingOut = false;

  final _changesCtrl = StreamController<void>.broadcast();
  Stream<void> get changes => _changesCtrl.stream;
  StreamSubscription<void>? _sessionSub;

  void _emit() {
    if (!_changesCtrl.isClosed) _changesCtrl.add(null);
  }

  /// Update cached user (after profile update)
  void setUserFromMap(Map<String, dynamic> userMap) {
    if (!state.isAuthenticated) return;
    state = state.copyWith(user: AuthUser.fromMap(userMap));
    _emit();
  }

  /// Initialize session from SharedPreferences
  Future<void> init() async {
    try {
      // 🔁 Listen for session expiry (401 from backend)
      _sessionSub ??= _apiClient.sessionExpiredStream.listen((_) async {
        if (!state.isAuthenticated || _isLoggingOut) return;

        _isLoggingOut = true;
        await logout();
        _isLoggingOut = false;
      });

      // 🔐 Restore SID from storage
      final sid = await _storage.getSid();

      if (sid == null || sid.isEmpty) {
        state = state.copyWith(initializing: false, isLoggedIn: false);
        _emit();
        return;
      }

      // 🍪 Attach SID to ApiClient (CookieManager)
      await _apiClient.setSid(sid);

      // ✅ Validate session with backend
      final res = await _api.me();

      if (res.isLeft) {
        await _clearSession();
        _emit();
        return;
      }

      final payload = res.rightOrNull ?? {};
      if (payload['ok'] != true) {
        await _clearSession();
        _emit();
        return;
      }

      // 👤 Extract user
      final user = Map<String, dynamic>.from(payload['data']?['user'] ?? {});

      // ✅ Update auth state
      state = state.copyWith(
        initializing: false,
        isLoggedIn: true,
        sid: sid,
        user: AuthUser.fromMap(user),
        clearError: true,
      );

      // 🌍 Sync preferences
      await _syncUserPreferences();

      _emit();
    } catch (_) {
      await _clearSession();
      _emit();
    }
  }

  Future<void> _clearSession() async {
    await _storage.clearSid();
    await _apiClient.clearSid();

    state = state.copyWith(
      initializing: false,
      isLoggedIn: false,
      clearSid: true,
      clearUser: true,
    );

    _emit();
  }

  Future<void> _syncUserPreferences() async {
    try {
      final prefApi = _ref.read(userPreferenceApiProvider);
      final prefCtrl = _ref.read(userPreferenceControllerProvider.notifier);

      final res = await prefApi.getMyPreferences();

      if (res.isLeft) return;

      final payload = res.rightOrNull ?? const {};

      if (payload['ok'] != true) return;

      final data = Map<String, dynamic>.from(payload['data'] ?? const {});

      final country = Map<String, dynamic>.from(data['country'] ?? const {});
      final language = Map<String, dynamic>.from(data['language'] ?? const {});
      final currency = Map<String, dynamic>.from(data['currency'] ?? const {});

      final countryCode = (country['code'] ?? '').toString();
      final languageCode = (language['code'] ?? '').toString();
      final currencyCode = (currency['name'] ?? '').toString();

      await prefCtrl.syncFromServer(
        countryCode: countryCode,
        languageCode: languageCode,
        currencyCode: currencyCode,
      );
    } catch (_) {}
  }

  // EMAIL LOGIN
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

    final data = Map<String, dynamic>.from(payload['data'] ?? {});
    final sid = data['sid']?.toString() ?? '';

    if (sid.isEmpty) {
      return Either.left(const Failure('Login failed (no session).'));
    }

    await _apiClient.setSid(sid);
    await _storage.setSid(sid);

    await _storage.setRememberMe(rememberMe);
    if (rememberMe) {
      await _storage.setRememberedEmail(email);
    } else {
      await _storage.clearRememberedEmail();
    }

    // Update auth state
    state = state.copyWith(
      initializing: false,
      isLoggedIn: true,
      sid: sid,
      user: AuthUser.fromMap(Map<String, dynamic>.from(data['user'] ?? {})),
      clearError: true,
    );

    // Sync preferences from server → SharedPreferences
    await _syncUserPreferences();

    _emit();
    _ref.invalidate(wishlistControllerProvider);

    return Either.right(null);
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}

    await _clearSession();
    _ref.invalidate(wishlistControllerProvider);
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

    final data = (payload['data'] is Map)
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : <String, dynamic>{};
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

  // GOOGLE LOGIN
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

      final data = Map<String, dynamic>.from(payload['data'] ?? {});
      final sid = (data['sid'] ?? '').toString();
      if (sid.isEmpty) {
        return Either.left(const Failure('No session returned.'));
      }

      await _apiClient.setSid(sid);
      await _storage.setSid(sid);

      state = state.copyWith(
        isLoggedIn: true,
        sid: sid,
        user: AuthUser.fromMap(Map<String, dynamic>.from(data['user'] ?? {})),
        clearError: true,
      );

      await _syncUserPreferences();

      _emit();
      _ref.invalidate(wishlistControllerProvider);

      return Either.right(null);
    } catch (e) {
      return Either.left(Failure('Google sign-in failed: $e'));
    }
  }

  // APPLE LOGIN
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

      final data = Map<String, dynamic>.from(payload['data'] ?? {});
      final sid = (data['sid'] ?? '').toString();

      if (sid.isEmpty) {
        return Either.left(const Failure('No session returned.'));
      }

      await _apiClient.setSid(sid);
      await _storage.setSid(sid);

      state = state.copyWith(
        isLoggedIn: true,
        sid: sid,
        user: AuthUser.fromMap(Map<String, dynamic>.from(data['user'] ?? {})),
        clearError: true,
      );

      await _syncUserPreferences();

      _emit();
      _ref.invalidate(wishlistControllerProvider);

      return Either.right(null);
    } catch (e) {
      return Either.left(Failure('Apple sign-in failed: $e'));
    }
  }

  Future<(bool remember, String email)> getRememberedLogin() async {
    final remember = await _storage.getRememberMe();
    final email = await _storage.getRememberedEmail();
    return (remember, remember ? email : '');
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _changesCtrl.close();
    super.dispose();
  }
}
