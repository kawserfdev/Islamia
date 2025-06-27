import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamia/core/config/firebase_config.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/data/models/user/user_profile.dart';
import '../../services/storage/local_storage_service.dart';
import '../exceptions/database_exceptions.dart';
import '../exceptions/validation_exceptions.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  final LocalStorageService _localStorage = LocalStorageService();

  static const String _usersCollection = 'users';

  // Create user (both local and remote)
  Future<void> createUser(UserModel user) async {
    try {
      if (user.id == null || user.id!.isEmpty) {
        throw ValidationException.required('User ID');
      }

      // Validate user data
      _validateUserModel(user);

      // Save to local storage first
      await _localStorage.saveUser(user);

      // Save to Firestore
      await _saveUserToFirestore(user);
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to create user: ${e.toString()}', originalError: e);
    }
  }

  // Get user by ID (local first, then remote)
  Future<UserModel?> getUserById(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException.required('User ID');
      }

      // Try local storage first
      UserModel? user = await _localStorage.getUser();
      
      // Check if the local user matches the requested ID
      if (user?.id == userId) {
        return user;
      }
      
      // If not found locally or different user, try Firestore
      user = await _getUserFromFirestore(userId);
      if (user != null) {
        // Save to local for future use
        await _localStorage.saveUser(user);
      }
      
      return user;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get user: ${e.toString()}', originalError: e);
    }
  }

  // Get current user from local storage
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _localStorage.getUser();
    } catch (e) {
      throw DatabaseException('Failed to get current user: ${e.toString()}', originalError: e);
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      if (user.id == null || user.id!.isEmpty) {
        throw ValidationException.required('User ID');
      }

      // Validate user data
      _validateUserModel(user);

      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      // Update local storage
      await _localStorage.updateUser(updatedUser);

      // Update Firestore
      try {
        await _updateUserInFirestore(updatedUser);
      } catch (e) {
        print('Failed to sync user to Firestore: $e');
        // Continue with local update even if remote fails
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update user: ${e.toString()}', originalError: e);
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException.required('User ID');
      }

      // Get current user
      final currentUser = await getCurrentUser();
      if (currentUser?.id != userId) {
        throw const DatabaseException('User ID mismatch or user not found');
      }

      // Validate preferences
      _validateUserPreferences(preferences);

      // Update user with new preferences
      final updatedUser = currentUser!.copyWith(
        preferences: preferences,
        updatedAt: DateTime.now(),
      );

      await updateUser(updatedUser);
    } on ValidationException {
      rethrow;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to update user preferences: ${e.toString()}', originalError: e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException.required('User ID');
      }

      // Get current user
      final currentUser = await getCurrentUser();
      if (currentUser?.id != userId) {
        throw const DatabaseException('User ID mismatch or user not found');
      }

      // Validate profile
      _validateUserProfile(profile);

      // Update user with new profile
      final updatedUser = currentUser!.copyWith(
        profile: profile,
        updatedAt: DateTime.now(),
      );

      await updateUser(updatedUser);
    } on ValidationException {
      rethrow;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to update user profile: ${e.toString()}', originalError: e);
    }
  }

  // Update last login time
  Future<void> updateLastLoginTime(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException.required('User ID');
      }

      final currentUser = await getCurrentUser();
      if (currentUser?.id == userId) {
        final updatedUser = currentUser!.copyWith(
          lastLoginAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _localStorage.updateUser(updatedUser);
      }

      // Update Firestore
      try {
        await _firestore.collection(_usersCollection).doc(userId).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Failed to sync last login time to Firestore: $e');
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update last login time: ${e.toString()}', originalError: e);
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException.required('User ID');
      }

      // Delete from local storage
      await _localStorage.deleteUser();

      // Delete from Firestore
      await _deleteUserFromFirestore(userId);
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to delete user: ${e.toString()}', originalError: e);
    }
  }

  // Sync user data with Firestore
  Future<void> syncUserData() async {
    try {
      final localUser = await getCurrentUser();
      if (localUser == null || localUser.id == null) return;

      // Get latest data from Firestore
      final remoteUser = await _getUserFromFirestore(localUser.id!);
      
      if (remoteUser == null) {
        // User doesn't exist remotely, create it
        await _saveUserToFirestore(localUser);
      } else {
        // Compare timestamps and sync accordingly
        final localUpdated = localUser.updatedAt ?? localUser.createdAt ?? DateTime.now();
        final remoteUpdated = remoteUser.updatedAt ?? remoteUser.createdAt ?? DateTime.now();
        
        if (remoteUpdated.isAfter(localUpdated)) {
          // Remote is newer, update local
          await _localStorage.saveUser(remoteUser);
        } else if (localUpdated.isAfter(remoteUpdated)) {
          // Local is newer, update remote
          await _updateUserInFirestore(localUser);
        }
      }

      await _localStorage.saveLastSyncTime(DateTime.now());
    } catch (e) {
      throw DatabaseException('Failed to sync user data: ${e.toString()}', originalError: e);
    }
  }

  // Check if sync is needed
  Future<bool> needsSync() async {
    try {
      final lastSync = await _localStorage.getLastSyncTime();
      if (lastSync == null) return true;
      
      final now = DateTime.now();
      final timeDifference = now.difference(lastSync);
      
      // Sync if more than 1 hour has passed
      return timeDifference.inHours >= 1;
    } catch (e) {
      return true; // Assume sync is needed if there's an error
    }
  }

  // Validation methods
  void _validateUserModel(UserModel user) {
    if (user.email != null && user.email!.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(user.email!)) {
        throw ValidationException.invalidFormat('Email', expectedFormat: 'example@domain.com');
      }
    }

    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(user.phoneNumber!)) {
        throw ValidationException.invalidFormat('Phone number', expectedFormat: '+1234567890');
      }
    }

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      if (user.displayName!.length < 2) {
        throw ValidationException.tooShort('Display name', 2);
      }
      if (user.displayName!.length > 50) {
        throw ValidationException.tooLong('Display name', 50);
      }
    }
  }

  void _validateUserPreferences(UserPreferences preferences) {
    if (preferences.fontSize < 8.0 || preferences.fontSize > 32.0) {
      throw ValidationException.outOfRange('Font size', min: 8.0, max: 32.0);
    }

    if (!['en', 'ar', 'bn', 'ur', 'tr', 'fr', 'de', 'es'].contains(preferences.language)) {
      throw ValidationException.invalidFormat('Language', expectedFormat: 'Supported language code');
    }

    if (!['ISNA', 'MWL', 'Egypt', 'Makkah', 'Karachi', 'Tehran', 'Jafari'].contains(preferences.calculationMethod)) {
      throw ValidationException.invalidFormat('Calculation method');
    }

    if (!['Shafi', 'Hanafi', 'Maliki', 'Hanbali'].contains(preferences.madhab)) {
      throw ValidationException.invalidFormat('Madhab');
    }
  }

  void _validateUserProfile(UserProfile profile) {
    if (profile.firstName != null && profile.firstName!.isNotEmpty) {
      if (profile.firstName!.length > 30) {
        throw ValidationException.tooLong('First name', 30);
      }
    }

    if (profile.lastName != null && profile.lastName!.isNotEmpty) {
      if (profile.lastName!.length > 30) {
        throw ValidationException.tooLong('Last name', 30);
      }
    }

    if (profile.dateOfBirth != null) {
      final now = DateTime.now();
      final age = now.difference(profile.dateOfBirth!).inDays ~/ 365;
      if (age < 0 || age > 150) {
        throw ValidationException.outOfRange('Age', min: 0, max: 150);
      }
    }

    if (profile.gender != null && profile.gender!.isNotEmpty) {
      if (!['male', 'female', 'other'].contains(profile.gender!.toLowerCase())) {
        throw ValidationException.invalidFormat('Gender', expectedFormat: 'male, female, or other');
      }
    }
  }

  // Private methods for Firestore operations
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      final data = user.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_usersCollection).doc(user.id).set(data);
    } catch (e) {
      throw DatabaseException.fromFirestore(e);
    }
  }

  Future<UserModel?> _getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      
      if (!doc.exists || doc.data() == null) return null;
      
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw DatabaseException.fromFirestore(e);
    }
  }

  Future<void> _updateUserInFirestore(UserModel user) async {
    try {
      final data = user.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();
      data.remove('createdAt'); // Don't update creation time
      
      await _firestore.collection(_usersCollection).doc(user.id).update(data);
    } catch (e) {
      throw DatabaseException.fromFirestore(e);
    }
  }

  Future<void> _deleteUserFromFirestore(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw DatabaseException.fromFirestore(e);
    }
  }

  // Stream for real-time updates
  Stream<UserModel?> getUserStream(String userId) {
    try {
      return _firestore
          .collection(_usersCollection)
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final user = UserModel.fromJson(snapshot.data()!);
          // Update local storage in background
          _localStorage.saveUser(user).catchError((e) => print('Failed to save user locally: $e'));
          return user;
        }
        return null;
      });
    } catch (e) {
      throw DatabaseException.fromFirestore(e);
    }
  }
}