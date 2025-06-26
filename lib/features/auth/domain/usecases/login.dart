import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../user.dart';
import '../auth_repository.dart';

class LoginUser {
  final AuthRepository repository;
  LoginUser(this.repository);

  Future<Either<Failure, LoginResult>> call(String username, String password) {
    return repository.login(username, password);
  }
}
