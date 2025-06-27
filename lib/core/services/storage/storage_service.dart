import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../firebase/firebase_config.dart';
import '../exceptions/service_exception.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseConfig.storage;

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('profile_images').child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServiceException('Failed to upload profile image: $e');
    }
  }

  // Upload profile image from bytes
  Future<String> uploadProfileImageFromBytes(
    String userId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child('profile_images').child('profile_${userId}_$fileName');
      
      final uploadTask = ref.putData(imageBytes);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServiceException('Failed to upload profile image from bytes: $e');
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      final listResult = await _storage.ref().child('profile_images').listAll();
      
      for (final item in listResult.items) {
        if (item.name.contains('profile_$userId')) {
          await item.delete();
        }
      }
    } catch (e) {
      throw ServiceException('Failed to delete profile image: $e');
    }
  }

  // Upload file with progress tracking
  Future<String> uploadFileWithProgress(
    String path,
    File file,
    Function(double)? onProgress,
  ) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServiceException('Failed to upload file: $e');
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      throw ServiceException('Failed to get file metadata: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw ServiceException('Failed to delete file: $e');
    }
  }

  // Get download URL
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ServiceException('Failed to get download URL: $e');
    }
  }

  // Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

// List files in a directory
  Future<List<Reference>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final listResult = await ref.listAll();
      return listResult.items;
    } catch (e) {
      throw ServiceException('Failed to list files: $e');
    }
  }

  // Get file size
  Future<int> getFileSize(String path) async {
    try {
      final metadata = await getFileMetadata(path);
      return metadata.size ?? 0;
    } catch (e) {
      throw ServiceException('Failed to get file size: $e');
    }
  }

  // Update file metadata
  Future<void> updateFileMetadata(String path, Map<String, String> customMetadata) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.updateMetadata(SettableMetadata(customMetadata: customMetadata));
    } catch (e) {
      throw ServiceException('Failed to update file metadata: $e');
    }
  }
}
