import 'user.dart';

abstract class AuthRepository {
  Future<User?> login(String username, String password);
  Future<User?> register(
    String username,
    String email,
    String userType,
    String phone,
    String password,
    String fullName,
  );
}
