import 'package:dartz/dartz.dart';

import '/core/errors/exception.dart';
import '/core/errors/failures.dart';

import '../auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<Either<Failure, List<dynamic>>> call(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    try {
      final result = await repository.register(
        username,
        email,
        fullName,
        userType,
        phone,
        password,
      );
      return Right(result);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
