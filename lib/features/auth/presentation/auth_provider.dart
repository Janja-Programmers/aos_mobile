import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user.dart';
import '../data/auth_remote_datasource.dart';

class AuthProvider with ChangeNotifier {
  final AuthRemoteDataSource dataSource;

  User? user;

  AuthProvider(this.dataSource);

  bool get isLoggedIn => user != null;

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

  Future<void> login(String usr, String pwd) async {
    final result = await dataSource.login(usr, pwd);

    if (result.containsKey('message') && result['message'] == 'Logged In') {
      user = User(username: usr);
      await persistUser(usr);
      notifyListeners();
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    final result = await dataSource.register(
      username,
      email,
      fullName,
      userType,
      phone,
      password,
    );

    if (result.containsKey('message') &&
        result['message'] == 'Already Registered') {
      user = User(username: username);
      await persistUser(username);
      notifyListeners();
    }

    return result;
  }
}
