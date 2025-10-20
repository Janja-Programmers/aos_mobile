import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;
  ResetPassword(this.repository);

  Future<Either<Failure, String>> call(String email) {
    return repository.resetPassword(email);
  }
}
