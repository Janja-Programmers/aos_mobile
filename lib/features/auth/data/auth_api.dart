import 'package:dio/dio.dart';

import 'package:aos_mobile/core/api/api_client.dart';
import 'package:aos_mobile/core/api/api_endpoints.dart';
import 'package:aos_mobile/core/api/api_response.dart';
import 'package:aos_mobile/core/api/dio_failure_mapper.dart';
import 'package:aos_mobile/core/api/failure.dart';
import 'package:aos_mobile/core/utils/either.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> googleLogin({
    required String idToken,
  }) async {
    final res = await _client.dio.post(
      ApiEndpoints.googleLoginEndpoint,
      data: {'id_token': idToken},
    );
    return unwrapFrappe(res);
  }

  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.registerEndpoint,
        data: {'email': email, 'password': password, 'full_name': fullName},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _client.dio.post(
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

  Future<Either<Failure, Map<String, dynamic>>> resendOtp({
    required String email,
  }) async {
    try {
      final res = await _client.dio.post(
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

  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> me() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.meEndpoint);
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> logout() async {
    try {
      final res = await _client.dio.post(ApiEndpoints.logoutEndpoint);
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  // Forgot password
  Future<Either<Failure, Map<String, dynamic>>> forgotPasswordRequest({
    required String email,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.forgotPasswordRequestEndpoint,
        data: {'email': email},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.forgotPasswordVerifyOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> forgotPasswordReset({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.forgotPasswordResetEndpoint,
        data: {
          'email': email,
          'reset_token': resetToken,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }

  // Change password (logged-in)
  Future<Either<Failure, Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }
}
