import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/domain/auth_entity.dart';
import 'package:africaonlinestores/features/auth/domain/auth_failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Use case for user registration
/// Validates user input and orchestrates the registration flow
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute registration with provided data
  Future<Either<AuthFailure, AuthSession>> call(RegisterParams params) async {
    // Validate email
    if (!_isValidEmail(params.email)) {
      return Either.left(
        const EmailValidationFailure('Please enter a valid email address'),
      );
    }

    // Validate full name
    if (params.fullName.trim().isEmpty) {
      return Either.left(
        AuthFailure('Full name cannot be empty'),
      );
    }

    if (params.fullName.length < 2) {
      return Either.left(
        AuthFailure('Full name must be at least 2 characters'),
      );
    }

    // Validate password
    final passwordValidation = _validatePassword(params.password);
    if (passwordValidation != null) {
      return Either.left(
        PasswordValidationFailure(
          'Password validation failed',
          validationErrors: passwordValidation,
        ),
      );
    }

    // Call repository
    return await _repository.register(
      email: params.email.trim().toLowerCase(),
      password: params.password,
      fullName: params.fullName.trim(),
      country: params.country,
      language: params.language,
      currency: params.currency,
    );
  }

  bool _isValidEmail(String email) {
    const emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  /// Validate password requirements
  /// Returns list of errors if invalid, null if valid
  List<String>? _validatePassword(String password) {
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('Password cannot be empty');
    }
    if (password.length < 8) {
      errors.add('Password must be at least 8 characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }

    return errors.isEmpty ? null : errors;
  }
}

/// Base failure class for non-specific errors
class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

/// Parameters for RegisterUseCase
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String? country;
  final String? language;
  final String? currency;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.country,
    this.language,
    this.currency,
  });

  @override
  List<Object?> get props =>
      [email, password, fullName, country, language, currency];
}
