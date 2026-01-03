import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/user_model.dart';
import '../../../../core/services/auth_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<UserModel> loginWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._authService);

  final AuthService _authService;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    return _fromFirebaseUser(user);
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    final firebaseUser = credential.user ?? _authService.currentUser;

    if (firebaseUser == null) {
      throw fb.FirebaseAuthException(
        code: 'user-not-found',
        message: 'Google sign-in failed. Please try again.',
      );
    }

    return _fromFirebaseUser(firebaseUser);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final credential = await _authService.signIn(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user ?? _authService.currentUser;

    if (firebaseUser == null) {
      throw fb.FirebaseAuthException(
        code: 'user-not-found',
        message: 'User not found. Please try again.',
      );
    }

    return _fromFirebaseUser(firebaseUser);
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final credential = await _authService.signUp(
      email: email,
      password: password,
      displayName: name,
    );
    final firebaseUser = credential.user ?? _authService.currentUser;

    if (firebaseUser == null) {
      throw fb.FirebaseAuthException(
        code: 'user-not-found',
        message: 'Account could not be created. Please try again.',
      );
    }

    return _fromFirebaseUser(firebaseUser);
  }

  UserModel _fromFirebaseUser(fb.User user) {
    final displayName = user.displayName?.trim();
    return UserModel(
      id: user.uid,
      name: displayName?.isNotEmpty == true
          ? displayName!
          : (user.email?.split('@').first ?? 'Student'),
      email: user.email ?? '',
      isAdmin: false,
    );
  }
}
