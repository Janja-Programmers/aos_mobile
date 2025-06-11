import '../domain/user.dart';
import '../domain/auth_repository.dart';

import 'auth_remote_datasource.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<User?> login(String username, String password) async {
    final data = await remote.login(username, password);
    return UserModel.fromJson(data);
  }

  @override
  Future<User?> register(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) async {
    final data = await remote.register(
      username,
      email,
      fullName,
      userType,
      phone,
      password,
    );
    return UserModel.fromJson(data);
  }
}
