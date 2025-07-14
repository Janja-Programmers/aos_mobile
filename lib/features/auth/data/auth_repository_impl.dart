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
    final result = await remote.login(username, password);

    return result.map((data) {
      final user = User(
        username: data['full_name'] ?? 'Guest',
        userType: data['user_type'] ?? 'Buyer',
      );
      final homePage = data['home_page'];
      return LoginResult(user: user, homePage: homePage);
    });
  }

  @override
  Future<List<dynamic>> register(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    final result = await remote.register(
      username,
      email,
      fullName,
      userType,
      phone,
      password,
    );

    return result.fold((failure) => throw Exception(failure.toString()), (
      data,
    ) {
      final message = data['message'];
      if (message is List) {
        return message;
      } else {
        throw Exception("Unexpected response structure");
      }
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return await remote.logout();
  }
}
