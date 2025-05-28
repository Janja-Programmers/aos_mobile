import '../domain/user.dart';
import '../domain/auth_repository.dart';

import 'auth_local_datasource.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource local;
  AuthRepositoryImpl(this.local);

  @override
  Future<User?> login(String username, String password) async {
    return await local.login(username, password);
  }

  @override
  Future<void> register(User user) async {
    final model = UserModel(username: user.username, password: user.password);
    await local.register(model);
  }
}
