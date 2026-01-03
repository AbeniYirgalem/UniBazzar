import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<User?> getCurrentUser() => remoteDataSource.getCurrentUser();

  @override
  Future<User> loginWithGoogle() => remoteDataSource.loginWithGoogle();

  @override
  Future<User> login({required String email, required String password}) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) {
    return remoteDataSource.register(name, email, password);
  }
}
