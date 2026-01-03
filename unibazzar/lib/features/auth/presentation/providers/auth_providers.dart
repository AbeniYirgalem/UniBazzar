import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/login_user.dart';
import '../../../auth/domain/usecases/login_with_google.dart';
import '../../../auth/domain/usecases/register_user.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/auth_service.dart';

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController({
    required this.loginUser,
    required this.loginWithGoogle,
    required this.registerUser,
    required this.authService,
  }) : super(const AsyncValue.data(null));

  final LoginUser loginUser;
  final LoginWithGoogle loginWithGoogle;
  final RegisterUser registerUser;
  final AuthService authService;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => loginUser(email, password));
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => loginWithGoogle());
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => registerUser(name: name, email: email, password: password),
    );
  }

  Future<void> logout() async {
    await authService.signOut();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>(
      (ref) => AuthController(
        loginUser: ref.read(loginUserProvider),
        loginWithGoogle: ref.read(loginWithGoogleProvider),
        registerUser: ref.read(registerUserProvider),
        authService: ref.read(authServiceProvider),
      ),
    );
