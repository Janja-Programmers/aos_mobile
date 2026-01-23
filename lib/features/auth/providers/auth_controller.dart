import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:aos_mobile/core/providers.dart';
import 'package:aos_mobile/core/api/api_client.dart';
import 'package:aos_mobile/core/api/session_storage.dart';
import 'package:aos_mobile/core/api/failure.dart';
import 'package:aos_mobile/core/utils/either.dart';
import 'package:aos_mobile/features/auth/data/auth_api.dart';
import 'package:aos_mobile/features/auth/domain/auth_state.dart';

final authRefreshProvider = StreamProvider<void>((ref) {
  // A lightweight stream that emits whenever authController changes.
  // It is used to refresh GoRouter.
  final ctrl = ref.watch(authControllerProvider.notifier);
  return ctrl.changes;
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final api = ref.watch(authApiProvider);
    final client = ref.watch(apiClientProvider);
    final storage = ref.watch(sessionStorageProvider);
    return AuthController(api: api, apiClient: client, storage: storage)
      ..init();
  },
);

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthApi api,
    required ApiClient apiClient,
    required SessionStorage storage,
  }) : _api = api,
       _apiClient = apiClient,
       _storage = storage,
       super(AuthState.initial());

  final AuthApi _api;
  final ApiClient _apiClient;
  final SessionStorage _storage;

  final _changesCtrl = StreamController<void>.broadcast();
  Stream<void> get changes => _changesCtrl.stream;

  void _emit() {
    if (!_changesCtrl.isClosed) _changesCtrl.add(null);
  }

  /// Update the cached user data (used after profile update).
  void setUserFromMap(Map<String, dynamic> userMap) {
    if (!state.isLoggedIn) return;
    state = state.copyWith(user: AuthUser.fromMap(userMap));
    _emit();
  }

  Future<void> init() async {
    // Load sid from storage and validate.
    try {
      final sid = await _storage.getSid();
      if (sid == null) {
        state = state.copyWith(initializing: false, isLoggedIn: false);
        _emit();
        return;
      }

      await _apiClient.setSid(sid);
      final res = await _api.me();

      if (res.isLeft) {
        await _storage.clearSid();
        await _apiClient.clearSid();
        state = state.copyWith(initializing: false, isLoggedIn: false);
        _emit();
        return;
      }

      final payload = res.rightOrNull ?? <String, dynamic>{};
      final ok = payload['ok'] == true;

      if (!ok) {
        await _storage.clearSid();
        await _apiClient.clearSid();
        state = state.copyWith(initializing: false, isLoggedIn: false);
        _emit();
        return;
      }

      final data = (payload['data'] is Map)
          ? Map<String, dynamic>.from(payload['data'] as Map)
          : <String, dynamic>{};
      final userMap = (data['user'] is Map)
          ? Map<String, dynamic>.from(data['user'] as Map)
          : <String, dynamic>{};

      state = state.copyWith(
        initializing: false,
        isLoggedIn: true,
        sid: sid,
        user: AuthUser.fromMap(userMap),
        clearError: true,
      );
      _emit();
    } catch (_) {
      await _storage.clearSid();
      await _apiClient.clearSid();
      state = state.copyWith(initializing: false, isLoggedIn: false);
      _emit();
    }
  }

  Future<Either<Failure, void>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final res = await _api.login(email: email, password: password);

    if (res.isLeft) {
      return Either.left(res.leftOrNull ?? const Failure('Login failed.'));
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      return Either.left(
        Failure((payload['message'] ?? 'Login failed.').toString()),
      );
    }

    final data = (payload['data'] is Map)
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : <String, dynamic>{};

    final sid = (data['sid'] ?? '').toString();
    if (sid.isEmpty) {
      return Either.left(const Failure('Login failed (no session).'));
    }

    // Persist session & remember me
    await _apiClient.setSid(sid);
    await _storage.setSid(sid);

    await _storage.setRememberMe(rememberMe);
    if (rememberMe) {
      await _storage.setRememberedEmail(email);
    } else {
      await _storage.clearRememberedEmail();
    }

    final userMap = (data['user'] is Map)
        ? Map<String, dynamic>.from(data['user'] as Map)
        : <String, dynamic>{};

    state = state.copyWith(
      initializing: false,
      isLoggedIn: true,
      sid: sid,
      user: AuthUser.fromMap(userMap),
      clearError: true,
    );
    _emit();

    return Either.right(null);
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // ignore network errors here; still clear local session.
    }
    await _storage.clearSid();
    await _apiClient.clearSid();

    state = state.copyWith(
      initializing: false,
      isLoggedIn: false,
      sid: null,
      user: null,
      clearError: true,
    );
    _emit();
  }

  Future<Either<Failure, String>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _api.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    if (res.isLeft) return Either.left(res.leftOrNull!);

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    final msg = (payload['message'] ?? (ok ? 'Success' : 'Failed')).toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
  }

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
    final msg = (payload['message'] ?? (ok ? 'Password changed' : 'Failed')).toString();
    return ok ? Either.right(msg) : Either.left(Failure(msg));
  }


  Future<(bool remember, String email)> getRememberedLogin() async {
    final remember = await _storage.getRememberMe();
    final email = await _storage.getRememberedEmail();
    return (remember, remember ? email : '');
  }

  @override
  void dispose() {
    _changesCtrl.close();
    super.dispose();
  }
}
