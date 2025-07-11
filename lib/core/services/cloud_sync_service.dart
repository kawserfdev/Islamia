import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user/user_profile.dart';
import '../database/user_database.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserDatabase _userDatabase = UserDatabase();

  // Collections
  static const String usersCollection = 'users';
  static const String backupsCollection = 'backups';
  static const String syncStatusCollection = 'sync_status';

  // Sync user profile to cloud
  Future<void> syncUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(profile.id)
          .set(profile.toFirestore(), SetOptions(merge: true));
      
      // Update sync status
      await _updateSyncStatus(profile.id, 'profile', DateTime.now());
    } catch (e) {
      print('Error syncing user profile: $e');
      throw e;
    }
  }

  // Sync user data from cloud
  Future<void> syncFromCloud(String userId) async {
    try {
      // Get user profile from cloud
      final profileDoc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (profileDoc.exists) {
        final cloudProfile = UserProfile.fromFirestore(profileDoc.data()!);
        final localProfile = await _userDatabase.getUserProfile(userId);

        // Compare timestamps and sync newer data
        if (localProfile == null || 
            (cloudProfile.updatedAt?.isAfter(localProfile.updatedAt ?? DateTime(1970)) ?? false)) {
          await _userDatabase.updateUserProfile(cloudProfile);
        } else if (localProfile.updatedAt?.isAfter(cloudProfile.updatedAt ?? DateTime(1970)) ?? false) {
          // Local is newer, sync to cloud
          await syncUserProfile(localProfile);
        }
      }

      // Sync other data types
      await _syncPrayerLogs(userId);
      await _syncReadingProgress(userId);
      await _syncAchievements(userId);
      
    } catch (e) {
      print('Error syncing from cloud: $e');
      throw e;
    }
  }

  // Create full backup
  Future<String> createBackup(String userId) async {
    try {
      // Export user data
      final userData = await _userDatabase.exportUserData(userId);
      
      // Create backup document
      final backupId = _generateBackupId(userId);
      final backupData = {
        'user_id': userId,
        'backup_id': backupId,
        'data': userData,
        'created_at': FieldValue.serverTimestamp(),
        'size': jsonEncode(userData).length,
        'version': '1.0',
      };

      // Save to Firestore
      await _firestore
          .collection(backupsCollection)
          .doc(backupId)
          .set(backupData);

      // Save backup reference in user document
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update({
        'last_backup': {
          'backup_id': backupId,
          'created_at': FieldValue.serverTimestamp(),
          'size': backupData['size'],
        }
      });

      return backupId;
    } catch (e) {
      print('Error creating backup: $e');
      throw e;
    }
  }

  // Restore from backup
  Future<void> restoreFromBackup(String userId, String backupId) async {
    try {
      // Get backup data
      final backupDoc = await _firestore
          .collection(backupsCollection)
          .doc(backupId)
          .get();

      if (!backupDoc.exists) {
        throw Exception('Backup not found');
      }

      final backupData = backupDoc.data()!;
      final userData = backupData['data'] as Map<String, dynamic>;

      // Restore profile
      if (userData['profile'] != null) {
        final profile = UserProfile.fromJson(userData['profile']);
        await _userDatabase.updateUserProfile(profile);
      }

      // Restore other data (prayer logs, reading progress, etc.)
      await _restoreUserData(userId, userData);

      // Update restore timestamp
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update({
        'last_restore': {
          'backup_id': backupId,
          'restored_at': FieldValue.serverTimestamp(),
        }
      });

    } catch (e) {
      print('Error restoring backup: $e');
      throw e;
    }
  }

  // Get available backups
  Future<List<Map<String, dynamic>>> getUserBackups(String userId) async {
    try {
      final query = await _firestore
          .collection(backupsCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'backup_id': doc.id,
          'created_at': data['created_at'],
          'size': data['size'],
          'version': data['version'],
        };
      }).toList();
    } catch (e) {
      print('Error getting backups: $e');
      return [];
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      
      // Upload file
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update user profile
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update({'photo_url': downloadUrl});

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw e;
    }
  }

  // Update last login
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update({
        'last_login_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Delete user data from cloud
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete user document
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .delete();

      // Delete backups
      final backupsQuery = await _firestore
          .collection(backupsCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in backupsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete profile picture
      try {
        await _storage.ref().child('profile_pictures/$userId.jpg').delete();
      } catch (e) {
        // Profile picture might not exist
      }

      // Delete sync status
      await _firestore
          .collection(syncStatusCollection)
          .doc(userId)
          .delete();

    } catch (e) {
      print('Error deleting user data from cloud: $e');
      throw e;
    }
  }

  // Check sync status
  Future<Map<String, dynamic>?> getSyncStatus(String userId) async {
    try {
      final doc = await _firestore
          .collection(syncStatusCollection)
          .doc(userId)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting sync status: $e');
      return null;
    }
  }

  // Private helper methods
  Future<void> _syncPrayerLogs(String userId) async {
    // Implementation for syncing prayer logs
    // This would involve comparing local and cloud prayer logs
    // and syncing the differences
  }

  Future<void> _syncReadingProgress(String userId) async {
    // Implementation for syncing reading progress
    // Similar pattern to prayer logs
  }

  Future<void> _syncAchievements(String userId) async {
    // Implementation for syncing achievements
  }

  Future<void> _restoreUserData(String userId, Map<String, dynamic> userData) async {
    // Implementation for restoring all user data from backup
    // This would involve restoring prayer logs, reading progress, etc.
  }

  Future<void> _updateSyncStatus(String userId, String dataType, DateTime timestamp) async {
    try {
      await _firestore
          .collection(syncStatusCollection)
          .doc(userId)
          .set({
        dataType: timestamp,
        'last_sync': timestamp,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating sync status: $e');
    }
  }

  String _generateBackupId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${userId}_backup_$timestamp';
  }

  // Real-time sync listeners
  StreamSubscription<DocumentSnapshot>? _profileSyncListener;

  void startRealTimeSync(String userId) {
    _profileSyncListener = _firestore
        .collection(usersCollection)
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _handleCloudProfileUpdate(snapshot.data()!);
      }
    });
  }

  void stopRealTimeSync() {
    _profileSyncListener?.cancel();
    _profileSyncListener = null;
  }

  void _handleCloudProfileUpdate(Map<String, dynamic> cloudData) async {
    try {
      final cloudProfile = UserProfile.fromFirestore(cloudData);
      final localProfile = await _userDatabase.getUserProfile(cloudProfile.id);

      // Only update if cloud version is newer
      if (localProfile == null || 
          (cloudProfile.updatedAt?.isAfter(localProfile.updatedAt ?? DateTime(1970)) ?? false)) {
        await _userDatabase.updateUserProfile(cloudProfile);
      }
    } catch (e) {
      print('Error handling cloud profile update: $e');
    }
  }
}