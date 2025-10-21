import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/constants/const.dart';
import '/core/db/clean_db.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import '../domain/user.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, LoginResult>> login(String usr, String pwd);
  Future<Either<Failure, List<dynamic>>> register(
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String>> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final APIClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Either<Failure, LoginResult>> login(
    String fullName,
    String password,
  ) async {
    try {
      final response = await apiClient.client.post(
        ApiRoutes.login,
        data: {'usr': fullName, 'pwd': password},
      );

      _setSessionCookie(response);

      final message = response.data['message'];
      final homePage = response.data['home_page'];
      final userType = message == "No App" ? "Buyer" : "Vendor";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', userType);
      await prefs.setString('email', fullName);

      final user = User(
        username: response.data['full_name'] ?? 'Guest',
        userType: userType,
        email: fullName,
      );

      return Right(LoginResult(user: user, homePage: homePage));
    } catch (error) {
      return Left(handleException(error));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> register(
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    try {
      final response = await apiClient.client.post(
        ApiRoutes.register,
        data: {
          "email": email,
          "full_name": fullName,
          "user_type": userType,
          "phone": phone,
          "password": password,
          "redirect_to": "/dashboard",
        },
      );

      _setSessionCookie(response);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        if (data.isEmpty && response.headers['set-cookie'] != null) {
          return Right([1, "Registration successful"]);
        }

        // ✅ Case 2: Frappe-style ["status", "message"]
        if (data["message"] is List && data["message"].length >= 2) {
          final status = data["message"][0];
          final message = data["message"][1].toString();
          return Right([status, message]);
        }

        // ✅ Case 3: Normal map with fields
        final status = data["status"] ?? 0;
        final message = data["message"]?.toString() ?? "Unknown response";
        return Right([status, message]);
      }

      return Left(ServerFailure("Unexpected response format"));
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final response = await apiClient.client.get(ApiRoutes.logout);

      apiClient.client.options.headers.remove('Cookie');

      if (response.statusCode == 200) {
        await clearAllTables();
        return const Right(null);
      } else {
        return Left(ServerFailure('Logout failed'));
      }
    } catch (e) {
      return Left(handleException(e));
    }
  }

  void _setSessionCookie(Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      final sidCookie = setCookie.firstWhere(
        (cookie) => cookie.startsWith('sid='),
        orElse: () => '',
      );
      final sid = sidCookie.split(';').first.split('=').last;

      if (sid.isNotEmpty) {
        apiClient.client.options.headers['Cookie'] = 'sid=$sid';
      }
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword(String email) async {
    try {
      final response = await apiClient.client.post(
        ApiRoutes.resetPassword,
        data: {"user": email},
      );

      // Successful response with _server_messages
      if (response.statusCode == 200 &&
          response.data.containsKey('_server_messages')) {
        final serverMessages = response.data['_server_messages'];

        // Decode the stringified JSON array
        final decoded = jsonDecode(serverMessages);
        if (decoded is List && decoded.isNotEmpty) {
          final messageData = jsonDecode(decoded.first);
          final message = messageData['message'] ?? 'Password reset email sent';
          return Right(message);
        }

        return Right('Password reset email sent');
      }

      // Handle known error responses
      final message = response.data['message'];
      switch (message) {
        case 'not found':
          return Left(ServerFailure('Email not registered.'));
        case 'not allowed':
          return Left(ServerFailure('Admin password cannot be reset.'));
        case 'disabled':
          return Left(ServerFailure('User account is disabled.'));
        default:
          return Left(ServerFailure('Unknown error occurred.'));
      }
    } catch (error) {
      // Fallback for usage limit HTML or network issues
      if (error is DioError && error.response?.data is String) {
        final data = error.response?.data as String;
        if (data.contains('Daily Usage Limit Reached')) {
          return Left(
            ServerFailure('Daily reset limit reached. Try again tomorrow.'),
          );
        }
      }

      return Left(handleException(error));
    }
  }
}
