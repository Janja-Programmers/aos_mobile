import 'package:flutter/material.dart';
import '../domain/user.dart';
import '../data/auth_remote_datasource.dart';

class AuthProvider with ChangeNotifier {
  final AuthRemoteDataSource dataSource;

  User? user;

  AuthProvider(this.dataSource);

  Future<void> login(String usr, String pwd) async {
    final result = await dataSource.login(usr, pwd);

    if (result.containsKey('message') && result['message'] == 'Logged In') {
      user = User(username: usr);
      notifyListeners();
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> logout() async {
    user = null;
    notifyListeners();
  }
}
