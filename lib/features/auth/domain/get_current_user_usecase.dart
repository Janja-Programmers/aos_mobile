import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/domain/auth_entity.dart';
import 'package:africaonlinestores/features/auth/domain/auth_failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_repository.dart';

/// Use case for fetching currently authenticated user
/// Used to restore auth state on app startup or check session validity
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Fetch and return the current authenticated user
  /// Returns [UserEntity] on success or [AuthFailure] on failure
  Future<Either<AuthFailure, UserEntity>> call() async {
    return await _repository.getCurrentUser();
  }
}
