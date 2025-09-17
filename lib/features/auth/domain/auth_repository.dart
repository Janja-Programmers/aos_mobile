import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'user.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResult>> login(String fullName, String password);

  Future<Either<Failure, List<dynamic>>> register(
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  );

  Future<Either<Failure, void>> logout();
}
