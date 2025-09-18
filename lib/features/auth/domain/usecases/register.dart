import 'package:dartz/dartz.dart';

import '/core/errors/exception.dart';
import '/core/errors/failures.dart';

import '../auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<Either<Failure, List<dynamic>>> call(
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    try {
      return await repository.register(
        email,
        fullName,
        userType,
        phone,
        password,
      );
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
