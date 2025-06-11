import '../user.dart';
import '../auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<User?> call(
    String username,
    String email,
    String fullName,
    String userType,
    String phone,
    String password,
  ) =>
      repository.register(username, email, userType, phone, password, fullName);
}
