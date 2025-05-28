import '../user.dart';
import '../auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<void> call(User user) => repository.register(user);
}
