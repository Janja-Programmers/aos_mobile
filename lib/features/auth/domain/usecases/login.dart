import '../user.dart';
import '../auth_repository.dart';

class LoginUser {
  final AuthRepository repository;
  LoginUser(this.repository);

  Future<User?> call(String username, String password) =>
      repository.login(username, password);
}
