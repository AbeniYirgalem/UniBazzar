import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this.repository);

  final AuthRepository repository;

  Future<User> call(String email, String password) {
    return repository.login(email: email, password: password);
  }
}
