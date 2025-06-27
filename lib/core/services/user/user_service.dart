import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/data/models/user/user_profile.dart';
import '../base/base_service.dart';
import '../firebase/firebase_config.dart';
import '../exceptions/service_exception.dart';
import '../storage/storage_service.dart';

class UserService extends BaseService<UserModel> {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() : super('users');

  final StorageService _storageService = StorageService();

  @override
  UserModel fromJson(Map<String, dynamic> json) => UserModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(UserModel model) => model.toJson();

  // Create user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      if (user.id == null) {
        throw const ValidationException('User ID cannot be null');
      }

      final data = toJson(user);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await doc(user.id!).set(data);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServiceException('Failed to create user profile: $e');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      throw ServiceException('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      if (user.id == null) {
        throw const ValidationException('User ID cannot be null');
      }

      final data = toJson(user);
      data['updatedAt'] = FieldValue.serverTimestamp();
      data.remove('createdAt'); // Don't update creation time

      await doc(user.id!).update(data);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServiceException('Failed to update user profile: $e');
    }
  }

  // Update specific user fields
  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      await doc(userId).update(fields);
    } catch (e) {
      throw ServiceException('Failed to update user fields: $e');
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await updateUserFields(userId, {
        'preferences': preferences.toJson(),
      });
    } catch (e) {
      throw ServiceException('Failed to update user preferences: $e');
    }
  }

  // Update user profile info
  Future<void> updateUserProfileInfo(String userId, UserProfile profile) async {
    try {
      await updateUserFields(userId, {
        'profile': profile.toJson(),
      });
    } catch (e) {
      throw ServiceException('Failed to update user profile info: $e');
    }
  }

  // Update profile image
  Future<String> updateProfileImage(String userId, File imageFile) async {
    try {
      // Upload image to Firebase Storage
      final imageUrl = await _storageService.uploadProfileImage(userId, imageFile);
      
      // Update user profile with new image URL
      await updateUserFields(userId, {
        'photoURL': imageUrl,
      });

      return imageUrl;
    } catch (e) {
      throw ServiceException('Failed to update profile image: $e');
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      // Delete from storage
      await _storageService.deleteProfileImage(userId);
      
      // Update user profile
      await updateUserFields(userId, {
        'photoURL': FieldValue.delete(),
      });
    } catch (e) {
      throw ServiceException('Failed to delete profile image: $e');
    }
  }

  // Update last login time
  Future<void> updateLastLoginTime(String userId) async {
    try {
      await updateUserFields(userId, {
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServiceException('Failed to update last login time: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      // Delete profile image if exists
      try {
        await _storageService.deleteProfileImage(userId);
      } catch (e) {
        // Ignore if image doesn't exist
      }

      // Delete user document
      await doc(userId).delete();
    } catch (e) {
      throw ServiceException('Failed to delete user profile: $e');
    }
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final docSnapshot = await doc(userId).get();
      return docSnapshot.exists;
    } catch (e) {
      throw ServiceException('Failed to check if user exists: $e');
    }
  }

  // Search users by display name
  Future<List<UserModel>> searchUsersByDisplayName(
    String searchTerm, {
    int limit = 20,
  }) async {
    try {
      final query = collection
          .where('displayName', isGreaterThanOrEqualTo: searchTerm)
          .where('displayName', isLessThan: '${searchTerm}z')
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
    } catch (e) {
      throw ServiceException('Failed to search users: $e');
    }
  }

  // Get users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];
      
      // Firestore 'in' queries are limited to 10 items
      final chunks = <List<String>>[];
      for (int i = 0; i < userIds.length; i += 10) {
        chunks.add(userIds.sublist(i, i + 10 > userIds.length ? userIds.length : i + 10));
      }

      final List<UserModel> users = [];
      for (final chunk in chunks) {
        final query = collection.where(FieldPath.documentId, whereIn: chunk);
        final snapshot = await query.get();
        users.addAll(snapshot.docs.map((doc) => fromJson(doc.data())));
      }

      return users;
    } catch (e) {
      throw ServiceException('Failed to get users by IDs: $e');
    }
  }

  // Get user profile stream for real-time updates
  Stream<UserModel?> getUserProfileStream(String userId) {
    try {
      return doc(userId).snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return fromJson(snapshot.data()!);
        }
        return null;
      });
    } catch (e) {
      throw ServiceException('Failed to get user profile stream: $e');
    }
  }

  // Batch update users
  Future<void> batchUpdateUsers(Map<String, Map<String, dynamic>> updates) async {
    try {
      final batch = FirebaseConfig.firestore.batch();
      
      updates.forEach((userId, fields) {
        fields['updatedAt'] = FieldValue.serverTimestamp();
        batch.update(doc(userId), fields);
      });

      await batch.commit();
    } catch (e) {
      throw ServiceException('Failed to batch update users: $e');
    }
  }

  // Export user data
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final user = await getUserProfile(userId);
      if (user == null) {
        throw const ServiceException('User not found');
      }

      return {
        'profile': toJson(user),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw ServiceException('Failed to export user data: $e');
    }
  }

  // Validate user data
  void validateUserData(UserModel user) {
    if (user.id == null || user.id!.isEmpty) {
      throw const ValidationException('User ID is required');
    }

    if (user.email != null && !_isValidEmail(user.email!)) {
      throw const ValidationException('Invalid email format');
    }

    if (user.phoneNumber != null && !_isValidPhoneNumber(user.phoneNumber!)) {
      throw const ValidationException('Invalid phone number format');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phoneNumber);
  }
}