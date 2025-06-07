import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/const.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String usr, String pwd);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  Logger? logger;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login(String usr, String pwd) async {
    final response = await dio.post(
      LOGIN_ENDPOINT,
      data: {'usr': usr, 'pwd': pwd},
    );

    // extract 'sid' from Set-Cookie header
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      final sidCookie = setCookie.firstWhere(
        (cookie) => cookie.startsWith('sid='),
        orElse: () => '',
      );
      final sid = sidCookie.split(';').first.split('=').last;

      // Store this for future use (e.g., shared_preferences, memory, etc.)
      logger?.i('Session ID extracted from cookie: $sid');

      // Add it to headers for future requests
      dio.options.headers['Cookie'] = 'sid=$sid';
    }

    return response.data;
  }
}
