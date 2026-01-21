import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _client.dio.post(
      '/api/method/aos.api.auth.register',
      data: {'email': email, 'password': password, 'full_name': fullName},
    );
    return _unwrap(res);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _client.dio.post(
      '/api/method/aos.api.auth.verify_email_otp',
      data: {'email': email, 'otp': otp},
    );
    return _unwrap(res);
  }

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final res = await _client.dio.post(
      '/api/method/aos.api.auth.resend_email_otp',
      data: {'email': email},
    );
    return _unwrap(res);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.dio.post(
      '/api/method/aos.api.auth.login',
      data: {'email': email, 'password': password},
    );
    return _unwrap(res);
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _client.dio.get('/api/method/aos.api.auth.me');
    return _unwrap(res);
  }

  Future<Map<String, dynamic>> logout() async {
    final res = await _client.dio.post('/api/method/aos.api.auth.logout');
    return _unwrap(res);
  }

  Map<String, dynamic> _unwrap(Response res) {
    final data = res.data;

    // Frappe wraps method response like: {"message": {...}}
    if (data is Map && data['message'] is Map) {
      return Map<String, dynamic>.from(data['message'] as Map);
    }

    if (data is Map && data.containsKey('message') && data['message'] is! Map) {
      return {'ok': true, 'message': data['message'].toString()};
    }

    if (data is Map) return Map<String, dynamic>.from(data);

    return {'ok': false, 'message': 'Unexpected response from server'};
  }
}
