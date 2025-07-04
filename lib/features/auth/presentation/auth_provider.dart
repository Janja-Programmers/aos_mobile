import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/utils/logger.dart';
import '/core/errors/failures.dart';

import '../domain/usecases/register.dart';
import '../domain/usecases/login.dart';
import '../domain/user.dart';

class AuthProvider with ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  User? user;
  String? _returnTo;
  String? _defaultHome;

  AuthProvider({required this.loginUser, required this.registerUser});

  bool get isLoggedIn => user != null;

  String get defaultHome => _defaultHome ?? '/';

  void setReturnTo(String path) {
    if (path != '/' && path != '/login' && path != '/register') {
      _returnTo = path;
      appLogger.i('🧭 setReturnTo: $path');
    } else {
      appLogger.i('⚠️ Ignored returnTo: $path');
    }
  }

  String? consumeReturnTo() {
    final temp = _returnTo;
    _returnTo = null;
    appLogger.i('🧭 Consuming returnTo: $temp');
    return temp;
  }

  Future<Either<Failure, void>> login(String username, String password) async {
    final result = await loginUser(username, password);
    if (result.isLeft()) return result;

    final loginResult = result.getOrElse(
      () => throw Exception('Unexpected null'),
    );

    user = loginResult.user;
    appLogger.i('💡 Logged in as: ${user?.username}, type: ${user?.userType}');

    _defaultHome = _mapHomePage(
      loginResult.homePage,
    ); // ✅ This is now used post-login
    appLogger.i('🏠 _defaultHome set to: $_defaultHome by auth prov');

    await persistUser(user!.username, user!.userType ?? '');
    notifyListeners();

    return const Right(null);
  }

  String _mapHomePage(String? homePage) {
    if (homePage == null || homePage.contains('/all-products')) return '/';
    if (homePage.contains('/app')) return '/dashboard';
    return '/'; // fallback
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

  Future<void> persistUser(String username, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('userType', userType);
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final userType = prefs.getString('userType');

    if (username != null) {
      user = User(username: username, userType: userType);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('userType');
    user = null;
    notifyListeners();
  }

  void clearRedirect() => _defaultHome = null;
}
