import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, Map<String, dynamic>>> login(String usr, String pwd);
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
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(
    String usr,
    String pwd,
  ) async {
    try {
      final response = await dio.post(
        LOGIN_ENDPOINT,
        data: {'usr': usr, 'pwd': pwd},
      );

      // Extract and save session cookie
      _setSessionCookie(response);

      return Right(response.data);
    } catch (e) {
      return Left(handleException(e));
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
      final response = await dio.post(
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
      final response = await dio.get(LOGOUT_ENDPOINT);

      dio.options.headers.remove('Cookie'); // clear session

      if (response.statusCode == 200) {
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
        dio.options.headers['Cookie'] = 'sid=$sid';
      }
    }
  }
}
