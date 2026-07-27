import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:dio/dio.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  /// GOOGLE LOGIN
  Future<Either<Failure, Map<String, dynamic>>> googleLogin({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.googleLoginEndpoint,
        data: {
          'id_token': idToken,
          'client_type': 'mobile',
          'country': country ?? '',
          'language': language ?? '',
          'currency': currency ?? '',
        },
      );

      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// APPLE LOGIN
  Future<Either<Failure, Map<String, dynamic>>> appleLogin({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.appleLoginEndpoint,
        data: {
          'id_token': idToken,
          'client_type': 'mobile',
          'country': country ?? '',
          'language': language ?? '',
          'currency': currency ?? '',
        },
      );
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// REGISTER
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
    String? country,
    String? language,
    String? currency,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.registerEndpoint,
        // countryPlacement: CountryPlacement.body,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'country': country ?? '',
          'language': language ?? '',
          'currency': currency ?? '',
        },
      );

      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// VERIFY OTP
  Future<Either<Failure, Map<String, dynamic>>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.verifyOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  /// RESEND OTP
  Future<Either<Failure, Map<String, dynamic>>> resendOtp({
    required String email,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.resendOtpEndpoint,
        data: {'email': email},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  /// LOGIN
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.loginEndpoint,
        data: {
          'identifier': identifier,
          'password': password,
          'client_type': 'mobile',
        },
      );
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// CURRENT USER
  Future<Either<Failure, Map<String, dynamic>>> me() async {
    try {
      final res = await _client.get(ApiEndpoints.meEndpoint);
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// LOGOUT
  Future<Either<Failure, Map<String, dynamic>>> logout() async {
    try {
      final res = await _client.post(ApiEndpoints.logoutEndpoint);
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// FORGOT PASSWORD REQUEST
  Future<Either<Failure, Map<String, dynamic>>> forgotPasswordRequest({
    required String email,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.forgotPasswordRequestEndpoint,
        data: {'email': email},
      );
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// FORGOT PASSWORD VERIFY OTP
  Future<Either<Failure, Map<String, dynamic>>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.forgotPasswordVerifyOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// RESET PASSWORD
  Future<Either<Failure, Map<String, dynamic>>> forgotPasswordReset({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.forgotPasswordResetEndpoint,
        data: {
          'email': email,
          'reset_token': resetToken,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// CHANGE PASSWORD
  Future<Either<Failure, Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      return unwrapFrappe(res);
    } catch (e) {
      return _mapError(e);
    }
  }

  /// ERROR MAPPER
  Either<Failure, Map<String, dynamic>> _mapError(Object e) {
    if (e is DioException) {
      return Either.left(mapDioException(e));
    }
    return Either.left(const Failure('Unexpected error. Please try again.'));
  }
}
