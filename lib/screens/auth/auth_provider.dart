import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/db/clean_db.dart';
import '/core/di/service_locator.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';

import '/features/auth/domain/auth_repository.dart';
import '/features/auth/domain/usecases/register.dart';
import '/features/auth/domain/usecases/login.dart';
import '/features/auth/domain/user.dart';

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

  bool _isLoading = false;
  String? _loginError;

  bool get isLoading => _isLoading;
  String? get loginError => _loginError;

  bool get isLoggedIn => user != null;
  String get defaultHome => _defaultHome ?? '/';
  String get home => _returnTo ?? _defaultHome ?? '/';

  String? _registerError;
  String? get registerError => _registerError;
  String? _registerSuccess;
  String? get registerSuccess => _registerSuccess;

  void setReturnTo(String path) {
    _returnTo = path;
  }

  String consumeReturnTo() {
    final path = _returnTo;
    _returnTo = null;
    return path ?? _defaultHome ?? '/';
  }

  // ✅ Wraps login + manages UI state
  Future<bool> signIn(String fullName, String password) async {
    _isLoading = true;
    _loginError = null;
    notifyListeners();

    final result = await login(fullName, password);

    final success = result.fold(
      (failure) {
        _loginError = failure.message;
        return false;
      },
      (_) {
        consumeReturnTo();
        return true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<Either<Failure, void>> login(
    String fullName,
    String password, {
    bool persist = true,
  }) async {
    final result = await loginUser(fullName, password);
    if (result.isLeft()) return result;

    final loginResult = result.getOrElse(
      () => throw Exception('Unexpected null'),
    );
    user = loginResult.user;
    _defaultHome = _mapHomePage(loginResult.homePage);

    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('full_name', fullName);
      await prefs.setString('password', password);
      await prefs.setString('userType', user?.userType ?? 'N/A');
    }

    notifyListeners();
    return const Right(null);
  }

  String _mapHomePage(String? homePage) {
    if (homePage == null || homePage.contains('/all-products')) return '/';
    if (homePage.contains('/app')) return '/dashboard';
    return '/';
  }

  Future<bool> signUp(
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    _registerError = null;
    _registerSuccess = null;
    notifyListeners();

    final result = await register(email, fullName, userType, phone, password);

    final success = result.fold(
      (failure) {
        _registerError = failure.message;
        return false;
      },
      (responseList) {
        final statusCode = int.tryParse(responseList[0].toString()) ?? 0;
        final message = responseList[1].toString();

        switch (statusCode) {
          case 0:
            _registerError = message;
            return false;
          case 1:
          case 2:
            _registerSuccess = message;
            return true;
          default:
            _registerError = "Unexpected status: $statusCode";
            return false;
        }
      },
    );

    notifyListeners();
    return success;
  }

  Future<Either<Failure, List<dynamic>>> register(
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    return await registerUser(email, fullName, userType, phone, password);
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('full_name');
    final password = prefs.getString('password');
    final userType = prefs.getString('userType');

    if (fullName == null || password == null) {
      return;
    }

    final result = await login(fullName, password, persist: false);

    result.fold((failure) => appLogger.w('⚠️ Failed to auto-restore session'), (
      _,
    ) {
      if (user != null) {
        user = user!.copyWith(userType: userType);
      }
      appLogger.i(
        '🪄 Session auto-restored: ${user?.fullName}, home: $_defaultHome',
      );
    });
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('full_name');
    final password = prefs.getString('password');

    if (fullName != null && password != null) {
      final result = await login(fullName, password, persist: false);
      result.fold(
        (failure) =>
            appLogger.w('⚠️ Failed to load user from persisted credentials'),
        (_) => appLogger.i('✅ User loaded via `loadUser()`'),
      );
    }
  }

  Future<void> logout() async {
    final result = await authRepo.logout();
    result.fold(
      (failure) => appLogger.e('❌ Logout API call failed: ${failure.message}'),
      (_) => appLogger.i('✅ Successfully logged out from Frappe'),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('full_name');
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.remove('userType');
    await clearAllTables();
    clearRedirect();

    user = null;
    _defaultHome = null;
    _returnTo = null;

    notifyListeners();
  }

  Future<Either<Failure, String>> deleteAccount(String password) async {
    try {
      final response = await apiClient.client.post(
        ApiRoutes.deleteUserAccount,
        data: {"password": password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data["success"] == true;
        final message = data["message"]?.toString() ?? "Unknown response";

        if (success) {
          // optional: clear user state here too
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          notifyListeners();
          return Right(message);
        }

        return Left(ServerFailure(message));
      }

      return Left(ServerFailure("Unexpected response format"));
    } catch (e) {
      return Left(handleException(e));
    }
  }

  void clearRedirect() => _returnTo = null;
}
