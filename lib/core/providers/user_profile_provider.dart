import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/auth_provider.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/data/models/user/user_profile.dart';
import 'package:islamia/domain/repositories/user_repository.dart';

// User profile controller provider
// final userProfileControllerProvider =
//     StateNotifierProvider<UserProfileController, UserProfileState>((ref) {
//       return UserProfileController(ref.read(userRepositoryProvider));
//     });

// User profile state
class UserProfileState {
  final bool isLoading;
  final String? error;
  final UserModel? user;
  final bool isUpdating;

  const UserProfileState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isUpdating = false,
  });

  UserProfileState copyWith({
    bool? isLoading,
    String? error,
    UserModel? user,
    bool? isUpdating,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

// User profile controller
class UserProfileController extends StateNotifier<UserProfileState> {
  final UserRepository _userRepository;

  UserProfileController(this._userRepository) : super(const UserProfileState());

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _userRepository.getCurrentUser();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUser(UserModel user) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      await _userRepository.updateUser(user);
      state = state.copyWith(isUpdating: false, user: user);
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      await _userRepository.updateUserPreferences(userId, preferences);

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(preferences: preferences);
        state = state.copyWith(isUpdating: false, user: updatedUser);
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      await _userRepository.updateUserProfile(userId, profile);

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(profile: profile);
        state = state.copyWith(isUpdating: false, user: updatedUser);
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> updateProfileImage(String userId, File imageFile) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final imageUrl = await _userRepository.updateProfileImage(
        userId,
        imageFile,
      );

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(photoURL: imageUrl);
        state = state.copyWith(isUpdating: false, user: updatedUser);
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      await _userRepository.deleteProfileImage(userId);

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(photoURL: null);
        state = state.copyWith(isUpdating: false, user: updatedUser);
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
