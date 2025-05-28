import 'user.dart';

abstract class AuthRepository {
  Future<User?> login(String username, String password);
  Future<void> register(User user);
}
