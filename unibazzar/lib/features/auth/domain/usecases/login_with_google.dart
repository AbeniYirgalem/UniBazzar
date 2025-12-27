import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  const LoginWithGoogle(this.repository);

  final AuthRepository repository;

  Future<User> call() => repository.loginWithGoogle();
}
