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
  String? _redirectPath;

  AuthProvider({required this.loginUser, required this.registerUser});

  bool get isLoggedIn => user != null;
  String? get redirectPath => _redirectPath;

  Future<Either<Failure, void>> login(String username, String password) async {
    final result = await loginUser(username, password);

    if (result.isLeft()) return result;

    final loginResult = result.getOrElse(
      () => throw Exception('Unexpected null'),
    );

    user = loginResult.user;
    appLogger.i('Logged in as: ${user?.username}, type: ${user?.userType}');

    // Redirect based on user type
    _redirectPath = user?.userType == 'Vendor' ? '/dashboard' : '/';
    appLogger.i('➡️ _redirectPath just set to: $_redirectPath');

    await persistUser(user!.username, user!.userType ?? '');

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

  void clearRedirect() => _redirectPath = null;
}
