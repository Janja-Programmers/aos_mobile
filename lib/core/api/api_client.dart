import 'package:dio/dio.dart';

/// API client for Frappe backend.
///
/// Notes:
/// - For session auth, we send `Cookie: sid=<sid>`
/// - We keep sid in memory and apply it to all requests
class ApiClient {
  ApiClient({required String baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // Helps debugging. Remove/adjust in production.
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  final Dio dio;

  String? _sid;

  String? get sid => _sid;

  void setSid(String sid) {
    _sid = sid;
    dio.options.headers['Cookie'] = 'sid=$sid';
  }

  void clearSid() {
    _sid = null;
    dio.options.headers.remove('Cookie');
  }
}
