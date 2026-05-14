import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/domain/auth_entity.dart';
import 'package:africaonlinestores/features/auth/domain/auth_failure.dart';

/// Abstract repository for authentication operations
/// Defines the contract that data layer must implement
/// Decouples business logic from data sources
abstract class AuthRepository {
  /// Login with email and password
  /// Returns [AuthSession] on success or [AuthFailure] on failure
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  /// Returns [AuthSession] on success or [AuthFailure] on failure
  Future<Either<AuthFailure, AuthSession>> register({
    required String email,
    required String password,
    required String fullName,
    String? country,
    String? language,
    String? currency,
  });

  /// Login with Google OAuth
  /// [idToken] is obtained from Google Sign-In
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  });

  /// Login with Apple OAuth
  /// [idToken] is obtained from Apple Sign-In
  Future<Either<AuthFailure, AuthSession>> loginWithApple({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  });

  /// Get current authenticated user
  /// Returns [UserEntity] on success or [AuthFailure] on failure
  Future<Either<AuthFailure, UserEntity>> getCurrentUser();

  /// Logout current user
  /// Clears session and tokens
  Future<Either<AuthFailure, void>> logout();

  /// Verify OTP for registration
  Future<Either<AuthFailure, AuthSession>> verifyOtp({
    required String email,
    required String otp,
  });

  /// Resend OTP to user email
  Future<Either<AuthFailure, void>> resendOtp({
    required String email,
  });

  /// Request password reset (forgot password)
  Future<Either<AuthFailure, void>> forgotPasswordRequest({
    required String email,
  });

  /// Verify OTP for password reset
  Future<Either<AuthFailure, void>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  });

  /// Reset password with verified OTP
  Future<Either<AuthFailure, void>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });

  /// Change password for authenticated user
  Future<Either<AuthFailure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
