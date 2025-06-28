import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamia/core/utils/extensions.dart';
import 'package:islamia/data/models/user/user_model.dart';
import '../services/auth/auth_service.dart';
import '../services/user/user_service.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  try {
    final authService = ref.read(authServiceProvider);
    final userService = ref.read(userServiceProvider);

    final firebaseUser = authService.currentUser;
    if (firebaseUser == null) return null;

    return await userService.getUserById(firebaseUser.uid);
  } catch (e) {
    print('Error getting current user: ${ExceptionHandler.getErrorMessage(e)}');
    return null;
  }
});

// User stream provider
final userStreamProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  final userService = ref.read(userServiceProvider);
  return userService.getUserStream(userId);
});

// Auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.read(authServiceProvider));
  },
);

// Auth state
class AuthState {
  final bool isLoading;
  final bool isGoogleLoading;
  final String? error;
  final bool isAuthenticated;
  final User? firebaseUser;
  final UserModel? userModel;
  final bool requiresEmailVerification;

  const AuthState({
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.firebaseUser,
    this.userModel,
    this.requiresEmailVerification = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isGoogleLoading,
    String? error,
    bool? isAuthenticated,
    User? firebaseUser,
    UserModel? userModel,
    bool? requiresEmailVerification,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
    );
  }

  bool get hasError => error != null;
  bool get canRetry => hasError && ExceptionHandler.isRetryableError(error);
}

// Auth controller
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      state = state.copyWith(isAuthenticated: user != null, firebaseUser: user);
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        firebaseUser: result.user,
        userModel: result.userModel,
        requiresEmailVerification: result.requiresEmailVerification,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ExceptionHandler.getErrorMessage(e),
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
        isAuthenticated: true,
        firebaseUser: result.user,
        userModel: result.userModel,
        requiresEmailVerification: result.requiresEmailVerification,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ExceptionHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isGoogleLoading: true, error: null);

    try {
      final result = await _authService.signInWithGoogle();

      state = state.copyWith(
        isGoogleLoading: false,
        isAuthenticated: true,
        firebaseUser: result.user,
        userModel: result.userModel,
        requiresEmailVerification: result.requiresEmailVerification,
      );
    } catch (e) {
      state = state.copyWith(
        isGoogleLoading: false,
        error: ExceptionHandler.getErrorMessage(e),
      );
    }
  }

  // Future<void> signInWithApple() async {
  //   state = state.copyWith(isLoading: true, error: null);

  //   try {
  //     final result = await _authService.signInWithApple();

  //     state = state.copyWith(
  //       isLoading: false,
  //       isAuthenticated: true,
  //       firebaseUser: result.user,
  //       userModel: result.userModel,
  //       requiresEmailVerification: result.requiresEmailVerification,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: ExceptionHandler.getErrorMessage(e),
  //     );
  //   }
  // }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.signInWithFacebook();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        firebaseUser: result.user,
        userModel: result.userModel,
        requiresEmailVerification: result.requiresEmailVerification,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ExceptionHandler.getErrorMessage(e),
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
        error: ExceptionHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> sendEmailVerification() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.sendEmailVerification();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ExceptionHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      final isVerified = await _authService.checkEmailVerification();
      if (isVerified && state.userModel != null) {
        state = state.copyWith(
          requiresEmailVerification: false,
          userModel: state.userModel!.copyWith(isEmailVerified: true),
        );
      }
    } catch (e) {
      state = state.copyWith(error: ExceptionHandler.getErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ExceptionHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.deleteAccount();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ExceptionHandler.getErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void retry() {
    if (state.canRetry) {
      clearError();
      // Implement retry logic based on the last action
    }
  }
}
