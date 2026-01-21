import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/providers.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/session_storage.dart';
import '../data/auth_api.dart';
import '../domain/auth_state.dart';

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

  Future<void> init() async {
    // Load sid from storage and validate.
    try {
      final sid = await _storage.getSid();
      if (sid == null) {
        state = state.copyWith(initializing: false, isLoggedIn: false);
        _emit();
        return;
      }

      _apiClient.setSid(sid);
      final res = await _api.me();
      final ok = res['ok'] == true;

      if (!ok) {
        await _storage.clearSid();
        _apiClient.clearSid();
        state = state.copyWith(initializing: false, isLoggedIn: false);
        _emit();
        return;
      }

      final data = (res['data'] is Map)
          ? Map<String, dynamic>.from(res['data'] as Map)
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
      _apiClient.clearSid();
      state = state.copyWith(initializing: false, isLoggedIn: false);
      _emit();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(clearError: true);

    final res = await _api.login(email: email, password: password);
    final ok = res['ok'] == true;
    if (!ok) {
      state = state.copyWith(
        errorMessage: (res['message'] ?? 'Login failed.').toString(),
      );
      _emit();
      return false;
    }

    final data = (res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : <String, dynamic>{};

    final sid = (data['sid'] ?? '').toString();
    if (sid.isEmpty) {
      state = state.copyWith(errorMessage: 'Login failed (no session).');
      _emit();
      return false;
    }

    _apiClient.setSid(sid);
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
    return true;
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // ignore network errors here; still clear local session.
    }

    await _storage.clearSid();
    _apiClient.clearSid();

    state = state.copyWith(
      initializing: false,
      isLoggedIn: false,
      sid: null,
      user: null,
      clearError: true,
    );
    _emit();
  }

  Future<(bool ok, String message)> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _api.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    final ok = res['ok'] == true;
    final msg = (res['message'] ?? (ok ? 'Success' : 'Failed')).toString();
    return (ok, msg);
  }

  Future<(bool ok, String message)> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _api.verifyOtp(email: email, otp: otp);
    final ok = res['ok'] == true;
    final msg = (res['message'] ?? (ok ? 'Verified' : 'Verification failed'))
        .toString();
    return (ok, msg);
  }

  Future<String> resendOtp({required String email}) async {
    final res = await _api.resendOtp(email: email);
    return (res['message'] ?? 'Sent').toString();
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
