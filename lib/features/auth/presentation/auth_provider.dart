import 'package:flutter/material.dart';
import '../domain/user.dart';
import '../domain/usecases/login.dart';
import '../domain/usecases/register.dart';

class AuthProvider with ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  User? _user;
  User? get user => _user;

  AuthProvider({required this.loginUser, required this.registerUser});

  Future<void> login(String username, String password) async {
    _user = await loginUser(username, password);
    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    await registerUser(User(username: username, password: password));
    notifyListeners();
  }
}
