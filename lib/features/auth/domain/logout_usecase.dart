import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/domain/auth_failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_repository.dart';

/// Use case for user logout
/// Clears authentication state and tokens
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout operation
  /// This operation cannot fail from business logic perspective
  /// If logout request fails, we still clear local state
  Future<Either<AuthFailure, void>> call() async {
    return await _repository.logout();
  }
}
