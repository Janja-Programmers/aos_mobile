import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'user.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResult>> login(String username, String password);

  Future<List<dynamic>> register(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  );
}
