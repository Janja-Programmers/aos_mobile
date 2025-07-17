import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/db/clean_db.dart';
import '/core/di/service_locator.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';

import '../domain/auth_repository.dart';
import '../domain/usecases/register.dart';
import '../domain/usecases/login.dart';
import '../domain/user.dart';

class AuthProvider with ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final APIClient apiClient;

  User? user;
  String? _defaultHome;
  String? _returnTo;

  AuthProvider({
    required this.loginUser,
    required this.registerUser,
    required this.apiClient,
  }) {
    Future.microtask(() => _restoreSession());
  }

  final authRepo = sl<AuthRepository>();

  bool get isLoggedIn => user != null;

  String get defaultHome => _defaultHome ?? '/';

  /// Home to navigate to (returnTo > default > fallback)
  String get home => _returnTo ?? _defaultHome ?? '/';

  /// Used by login screen to set redirect path
  void setReturnTo(String path) {
    _returnTo = path;
    appLogger.i('💡 ⤴️ returnTo set to: $path');
  }

  /// Used by login screen after successful login
  String consumeReturnTo() {
    final path = _returnTo;
    _returnTo = null;
    appLogger.i('💡 🧭 Consuming returnTo: $path');
    return path ?? _defaultHome ?? '/';
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');

    if (username == null || password == null) {
      appLogger.w('⚠️ No persisted credentials found.');
      return;
    }

    appLogger.i('🔄 Attempting session restore for: $username');
    final result = await login(username, password, persist: false);

    result.fold(
      (failure) => appLogger.w('⚠️ Failed to auto-restore session'),
      (_) => appLogger.i(
        '🪄 Session auto-restored: ${user?.username}, home: $_defaultHome',
      ),
    );
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');

    if (username != null && password != null) {
      final result = await login(username, password, persist: false);

      result.fold(
        (failure) {
          appLogger.w('⚠️ Failed to load user from persisted credentials');
        },
        (_) {
          appLogger.i('✅ User loaded via `loadUser()`');
        },
      );
    } else {
      appLogger.w('⚠️ No stored credentials to load user');
    }
  }

  Future<Either<Failure, void>> login(
    String username,
    String password, {
    bool persist = true,
  }) async {
    final result = await loginUser(username, password);
    if (result.isLeft()) return result;

    final loginResult = result.getOrElse(
      () => throw Exception('Unexpected null'),
    );
    user = loginResult.user;
    _defaultHome = _mapHomePage(loginResult.homePage);

    appLogger.i('💡 Logged in as: ${user?.username}, home: $_defaultHome');

    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('password', password);
    }

    notifyListeners();
    return const Right(null);
  }

  String _mapHomePage(String? homePage) {
    if (homePage == null || homePage.contains('/all-products')) return '/';
    if (homePage.contains('/app')) return '/dashboard';
    return '/';
  }

  Future<Either<Failure, List<dynamic>>> register(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    return await registerUser(
      username,
      email,
      fullName,
      userType,
      phone,
      password,
    );
  }

  Future<void> logout() async {
    final result = await authRepo.logout();

    result.fold(
      (failure) {
        appLogger.e('❌ Logout API call failed: ${failure.message}');
      },
      (_) {
        appLogger.i('✅ Successfully logged out from Frappe');
      },
    );

    // Clear local shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');

    // Clear local DB or cache (if using Hive, Isar, Drift, etc.)
    await clearAllTables();

    // Reset provider state
    user = null;
    _defaultHome = null;
    _returnTo = null;

    notifyListeners();
  }

  void clearRedirect() => _returnTo = null;
}
