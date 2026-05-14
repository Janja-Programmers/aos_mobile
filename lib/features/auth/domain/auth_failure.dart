import 'package:equatable/equatable.dart';

/// Domain-level failures specific to authentication operations
/// Mapped from network exceptions and API responses
sealed class AuthFailure extends Equatable {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Network-related auth failures
class NetworkAuthFailure extends AuthFailure {
  final int? statusCode;

  const NetworkAuthFailure(String message, {this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// Authentication credentials invalid (401)
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([String message = 'Invalid email or password'])
      : super(message);
}

/// User account not found
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([String message = 'User account not found'])
      : super(message);
}

/// Email already registered
class EmailAlreadyRegisteredFailure extends AuthFailure {
  const EmailAlreadyRegisteredFailure(
      [String message = 'Email already registered'])
      : super(message);
}

/// Password validation failed
class PasswordValidationFailure extends AuthFailure {
  final List<String>? validationErrors;

  const PasswordValidationFailure(String message,
      {this.validationErrors})
      : super(message);

  @override
  List<Object?> get props => [message, validationErrors];
}

/// Email validation failed
class EmailValidationFailure extends AuthFailure {
  const EmailValidationFailure([String message = 'Invalid email format'])
      : super(message);
}

/// OTP verification failed
class OtpVerificationFailure extends AuthFailure {
  const OtpVerificationFailure(
      [String message = 'OTP verification failed. Please try again.'])
      : super(message);
}

/// Session expired
class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure([String message = 'Session expired. Please login again'])
      : super(message);
}

/// Server error during auth
class ServerAuthFailure extends AuthFailure {
  const ServerAuthFailure([String message = 'Server error. Please try again later'])
      : super(message);
}

/// No internet connection
class NoInternetAuthFailure extends AuthFailure {
  const NoInternetAuthFailure(
      [String message = 'No internet connection'])
      : super(message);
}

/// Timeout during auth operation
class TimeoutAuthFailure extends AuthFailure {
  const TimeoutAuthFailure(
      [String message = 'Request timeout. Please try again.'])
      : super(message);
}

/// Unknown/unexpected auth error
class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure(
      [String message = 'An unexpected error occurred'])
      : super(message);
}

/// Too many login attempts
class TooManyAttemptsFailure extends AuthFailure {
  const TooManyAttemptsFailure(
      [String message = 'Too many login attempts. Please try again later.'])
      : super(message);
}
