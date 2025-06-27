import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/domain/repositories/user_repository.dart';
import '../services/auth/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepositoryImpl());

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final userRepository = ref.read(userRepositoryProvider);
  return await userRepository.getCurrentUser();
});

// User stream provider
final userStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.getUserStream(userId);
});

// Auth controller provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

// Auth state
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;
  final UserModel? userModel;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.userModel,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    UserModel? userModel,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      userModel: userModel ?? this.userModel,
    );
  }
}

// Auth controller
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      state = state.copyWith(
        isLoading: false,
        user: result.user,
        userModel: result.userModel,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      state = state.copyWith(
        isLoading: false,
        user: result.user,
        userModel: result.userModel,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Future<void> signInWithGoogle() async {
  //   state = state.copyWith(isLoading: true, error: null);
    
  //   try {
  //     final result = await _authService.signInWithGoogle();
      
  //     state = state.copyWith(
  //       isLoading: false,
  //       user: result.user,
  //       userModel: result.userModel,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: e.toString(),
  //     );
  //   }
  // }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}