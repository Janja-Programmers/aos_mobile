import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/domain/auth_entity.dart';
import 'package:africaonlinestores/features/auth/domain/auth_failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Use case for user login
/// Orchestrates the authentication flow with validation
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login with provided credentials
  /// Validates input before calling repository
  Future<Either<AuthFailure, AuthSession>> call(LoginParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return Either.left(
        const EmailValidationFailure('Please enter a valid email address'),
      );
    }

    // Validate password
    if (params.password.isEmpty) {
      return Either.left(
        const PasswordValidationFailure('Password cannot be empty'),
      );
    }

    if (params.password.length < 6) {
      return Either.left(
        const PasswordValidationFailure('Password must be at least 6 characters'),
      );
    }

    // Call repository
    return await _repository.login(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }

  bool _isValidEmail(String email) {
    const emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }
}

/// Parameters for LoginUseCase
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
