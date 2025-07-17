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
  Future<Either<Failure, Map<String, dynamic>>> register(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  );
  Future<Either<Failure, void>> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final APIClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Either<Failure, LoginResult>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await apiClient.client.post(
        LOGIN_ENDPOINT,
        data: {'usr': username, 'pwd': password},
      );

      _setSessionCookie(response);

      final message = response.data['message'];
      final homePage = response.data['home_page'];
      final userType = message == "No App" ? "Buyer" : "Vendor";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', userType);

      final user = User(
        username: response.data['full_name'] ?? 'Guest',
        userType: userType,
      );

      return Right(LoginResult(user: user, homePage: homePage));
    } catch (error) {
      return Left(handleException(error));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    try {
      final response = await apiClient.client.post(
        REGISTER_ENDPOINT,
        data: {
          'username': username,
          'email': email,
          'full_name': fullName,
          'user_type': userType,
          'phone': phone,
          'password': password,
          'redirect_to': "/dashboard",
        },
      );

      _setSessionCookie(response);

      return Right(response.data);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final response = await apiClient.client.get(LOGOUT_ENDPOINT);

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
}
