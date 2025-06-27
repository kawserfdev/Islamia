import 'dart:io';

import 'package:islamia/core/services/auth/auth_service.dart';
import 'package:islamia/core/services/exceptions/service_exception.dart';
import 'package:islamia/core/services/user/user_service.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/data/models/user/user_profile.dart';

abstract class UserRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> getUserById(String userId);
  Future<void> updateUser(UserModel user);
  Future<void> updateUserPreferences(String userId, UserPreferences preferences);
  Future<void> updateUserProfile(String userId, UserProfile profile);
  Future<String> updateProfileImage(String userId, File imageFile);
  Future<void> deleteProfileImage(String userId);
  Future<void> deleteUser(String userId);
  Stream<UserModel?> getUserStream(String userId);
  Future<List<UserModel>> searchUsers(String searchTerm);
  Future<bool> userExists(String userId);
}

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;
  
  final AuthService _authService;

  UserRepositoryImpl({
    UserService? userService,
    AuthService? authService,
  })  : _userService = userService ?? UserService(),
        _authService = authService ?? AuthService();

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return null;
      
      return await _userService.getUserProfile(currentUser.uid);
    } catch (e) {
      throw ServiceException('Failed to get current user: $e');
    }
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _userService.getUserProfile(userId);
    } catch (e) {
      throw ServiceException('Failed to get user by ID: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      _userService.validateUserData(user);
      await _userService.updateUserProfile(user);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServiceException('Failed to update user: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await _userService.updateUserPreferences(userId, preferences);
    } catch (e) {
      throw ServiceException('Failed to update user preferences: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      await _userService.updateUserProfileInfo(userId, profile);
    } catch (e) {
      throw ServiceException('Failed to update user profile: $e');
    }
  }

  @override
  Future<String> updateProfileImage(String userId, File imageFile) async {
    try {
      return await _userService.updateProfileImage(userId, imageFile);
    } catch (e) {
      throw ServiceException('Failed to update profile image: $e');
    }
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    try {
      await _userService.deleteProfileImage(userId);
    } catch (e) {
      throw ServiceException('Failed to delete profile image: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _userService.deleteUserProfile(userId);
    } catch (e) {
      throw ServiceException('Failed to delete user: $e');
    }
  }

  @override
  Stream<UserModel?> getUserStream(String userId) {
    try {
      return _userService.getUserProfileStream(userId);
    } catch (e) {
      throw ServiceException('Failed to get user stream: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String searchTerm) async {
    try {
      return await _userService.searchUsersByDisplayName(searchTerm);
    } catch (e) {
      throw ServiceException('Failed to search users: $e');
    }
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      return await _userService.userExists(userId);
    } catch (e) {
      throw ServiceException('Failed to check if user exists: $e');
    }
  }
}