import 'package:africaonlinestores/core/api/domain_exceptions.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/data/auth_remote_datasource.dart';
import 'package:africaonlinestores/features/auth/domain/auth_entity.dart';
import 'package:africaonlinestores/features/auth/domain/auth_failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_repository.dart';

/// Concrete implementation of AuthRepository
/// Bridges the domain layer (business logic) with the data layer (network/local storage)
/// Converts exceptions to domain failures
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDatasource.login(
        email: email,
        password: password,
      );
      return Either.right(model.toEntity());
    } on AuthenticationException catch (e) {
      return Either.left(InvalidCredentialsFailure(e.message));
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> register({
    required String email,
    required String password,
    required String fullName,
    String? country,
    String? language,
    String? currency,
  }) async {
    try {
      final model = await _remoteDatasource.register(
        email: email,
        password: password,
        fullName: fullName,
        country: country,
        language: language,
        currency: currency,
      );
      return Either.right(model.toEntity());
    } on ValidationException catch (e) {
      if (e.message.toLowerCase().contains('email')) {
        return Either.left(EmailAlreadyRegisteredFailure(e.message));
      }
      return Either.left(PasswordValidationFailure(e.message, validationErrors: e.errors?.values.toList().cast<String>()));
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  }) async {
    try {
      final model = await _remoteDatasource.loginWithGoogle(
        idToken: idToken,
        country: country,
        language: language,
        currency: currency,
      );
      return Either.right(model.toEntity());
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithApple({
    required String idToken,
    String? country,
    String? language,
    String? currency,
  }) async {
    try {
      final model = await _remoteDatasource.loginWithApple(
        idToken: idToken,
        country: country,
        language: language,
        currency: currency,
      );
      return Either.right(model.toEntity());
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> getCurrentUser() async {
    try {
      final model = await _remoteDatasource.getCurrentUser();
      return Either.right(model.toEntity());
    } on AuthenticationException catch (_) {
      return Either.left(
        const SessionExpiredFailure(),
      );
    } on NotFoundException catch (e) {
      return Either.left(UserNotFoundFailure(e.message));
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      await _remoteDatasource.logout();
      return Either.right(null);
    } on DomainException catch (e) {
      // Logout errors are non-critical, still consider it success
      return Either.right(null);
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final model = await _remoteDatasource.verifyOtp(
        email: email,
        otp: otp,
      );
      return Either.right(model.toEntity());
    } on ValidationException catch (e) {
      return Either.left(OtpVerificationFailure(e.message));
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> resendOtp({
    required String email,
  }) async {
    try {
      await _remoteDatasource.resendOtp(email: email);
      return Either.right(null);
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> forgotPasswordRequest({
    required String email,
  }) async {
    try {
      await _remoteDatasource.forgotPasswordRequest(email: email);
      return Either.right(null);
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _remoteDatasource.forgotPasswordVerifyOtp(
        email: email,
        otp: otp,
      );
      return Either.right(null);
    } on ValidationException catch (e) {
      return Either.left(OtpVerificationFailure(e.message));
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _remoteDatasource.resetPassword(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return Either.right(null);
    } on ValidationException catch (e) {
      return Either.left(PasswordValidationFailure(e.message));
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _remoteDatasource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return Either.right(null);
    } on ValidationException catch (e) {
      return Either.left(PasswordValidationFailure(e.message));
    } on DomainException catch (e) {
      return Either.left(_mapException(e));
    }
  }

  /// Map domain exceptions to auth-specific failures
  AuthFailure _mapException(DomainException e) {
    if (e is NetworkException) {
      return NetworkAuthFailure(e.message, statusCode: e.statusCode);
    } else if (e is TimeoutException) {
      return TimeoutAuthFailure(e.message);
    } else if (e is NoInternetException) {
      return NoInternetAuthFailure(e.message);
    } else if (e is ServerException) {
      return ServerAuthFailure(e.message);
    }
    return UnknownAuthFailure(e.message);
  }
}
