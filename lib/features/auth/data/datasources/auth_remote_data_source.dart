import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password) async {
    // Simulate API call by loading JSON from assets
    final String response = await rootBundle.loadString(
      'assets/json/users.json',
    );
    final List<dynamic> data = json.decode(response);
    final userJson = data.firstWhere((json) => json['email'] == email);
    return UserModel.fromJson(userJson);
  }

  Future<UserModel> register(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(id: '1', email: email);
  }
}
