import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/domain_exceptions.dart';
import 'package:africaonlinestores/features/auth/data/auth_response_model.dart';
import 'package:dio/dio.dart';

/// Abstract datasource for remote authentication operations
/// Defines the contract for network-based auth operations
abstract class AuthRemoteDatasource {
  /// Login with email and password
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    String? country,
    String? language,
    String? currency,
  });

  /// Login with Google OAuth
  Future<AuthResponseModel> loginWithGoogle({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  });

  /// Login with Apple OAuth
  Future<AuthResponseModel> loginWithApple({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  });

  /// Get current authenticated user
  Future<UserModel> getCurrentUser();

  /// Logout current user
  Future<void> logout();

  /// Verify OTP
  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  });

  /// Resend OTP
  Future<void> resendOtp({
    required String email,
  });

  /// Request password reset
  Future<void> forgotPasswordRequest({
    required String email,
  });

  /// Verify OTP for password reset
  Future<void> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  });

  /// Reset password
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

/// Implementation of AuthRemoteDatasource
/// Handles all network calls to authentication endpoints
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _client;

  AuthRemoteDatasourceImpl(this._client);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final data = _unwrapFrappe(res);
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Failed to login');
    }
  }

  @override
  Future<AuthResponseModel> register({
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
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'country': country ?? '',
          'language': language ?? '',
          'currency': currency ?? '',
        },
      );

      final data = _unwrapFrappe(res);
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Failed to register');
    }
  }

  @override
  Future<AuthResponseModel> loginWithGoogle({
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
          'country': country ?? '',
          'language': language ?? '',
          'currency': currency ?? '',
        },
      );

      final data = _unwrapFrappe(res);
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Google login failed');
    }
  }

  @override
  Future<AuthResponseModel> loginWithApple({
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
          'country': country ?? '',
          'language': language ?? '',
          'currency': currency ?? '',
        },
      );

      final data = _unwrapFrappe(res);
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Apple login failed');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final res = await _client.get(ApiEndpoints.meEndpoint);
      final data = _unwrapFrappe(res);
      return UserModel.fromJson(data['user'] ?? data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Failed to get current user');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logoutEndpoint);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Failed to logout');
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.verifyOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );

      final data = _unwrapFrappe(res);
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('OTP verification failed');
    }
  }

  @override
  Future<void> resendOtp({
    required String email,
  }) async {
    try {
      await _client.dio.post(
        ApiEndpoints.resendOtpEndpoint,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Failed to resend OTP');
    }
  }

  @override
  Future<void> forgotPasswordRequest({
    required String email,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.forgotPasswordRequestEndpoint,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Password reset request failed');
    }
  }

  @override
  Future<void> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.forgotPasswordVerifyOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('OTP verification failed');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.forgotPasswordResetEndpoint,
        data: {
          'email': email,
          'reset_token': resetToken,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Password reset failed');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Password change failed');
    }
  }

  /// Helper to unwrap Frappe API responses
  Map<String, dynamic> _unwrapFrappe(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['message'] ?? response;
    }
    return {};
  }

  /// Map Dio exceptions to domain exceptions
  DomainException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.message ?? 'Network error';

    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return AuthenticationException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 429:
        return ServerException('Too many requests. Please try again later.');
      case 500:
      case 502:
      case 503:
        return ServerException('Server error. Please try again later.');
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          return TimeoutException('Request timeout. Please try again.');
        }
        if (e.type == DioExceptionType.receiveTimeout) {
          return TimeoutException('Response timeout. Please try again.');
        }
        return NetworkException(message, statusCode: statusCode);
    }
  }
}
