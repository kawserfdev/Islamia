import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/auth/auth_service.dart';
import 'package:islamia/core/services/user/user_service.dart';
import 'package:islamia/domain/repositories/user_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userServiceProvider = Provider<UserService>((ref) => UserService());

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    userService: ref.read(userServiceProvider),
    authService: ref.read(authServiceProvider),
  );
});