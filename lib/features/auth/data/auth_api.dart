import 'package:dio/dio.dart';

import '/core/api/api_client.dart';

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

  Map<String, dynamic> _unwrap(Response res) {
    // Frappe wraps responses like: {"message": {...}}
    final data = res.data;
    if (data is Map && data['message'] is Map) {
      return Map<String, dynamic>.from(data['message']);
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'ok': false, 'message': 'Unexpected response from server'};
  }
}
