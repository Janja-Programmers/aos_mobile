import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/user.dart';
import '../domain/auth_repository.dart';
import '../data/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, LoginResult>> login(
    String username,
    String password,
  ) async {
    return await remote.login(username, password);
  }

  @override
  Future<Either<Failure, List<dynamic>>> register(
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    return await remote.register(email, fullName, userType, phone, password);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return await remote.logout();
  }

  @override
  Future<Either<Failure, String>> resetPassword(String email) async {
    return await remote.resetPassword(email);
  }
}
