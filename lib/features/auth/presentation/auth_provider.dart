import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/errors/failures.dart';

import '../domain/usecases/register.dart';
import '../domain/usecases/login.dart';
import '../domain/user.dart';

class AuthProvider with ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  User? user;
  String? _redirectPath;

  AuthProvider({required this.loginUser, required this.registerUser});

  bool get isLoggedIn => user != null;
  String? get redirectPath => _redirectPath;
  void clearRedirect() => _redirectPath = null;

  Future<Either<Failure, void>> login(String username, String password) async {
    final result = await loginUser(username, password);

    if (result.isLeft()) return result;

    final loginResult = result.getOrElse(
      () => throw Exception('Unexpected null'),
    );

    user = loginResult.user;
    appLogger.i('Redirecting to: ${loginResult.homePage}');
    _redirectPath = _mapFrappePath(loginResult.homePage);
    appLogger.i('Redirecting to: ${loginResult.homePage}');

    await persistUser(user!.username);

    notifyListeners();
    return const Right(null);
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

  Future<void> persistUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    if (username != null) {
      user = User(username: username);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    user = null;
    notifyListeners();
  }

  String _mapFrappePath(String path) {
    return path == '/all-products' ? '/' : '/products';
  }
}
