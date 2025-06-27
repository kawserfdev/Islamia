import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseConfig {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseMessaging? _messaging;

  static Future<void> initialize() async {
    _app = await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    _messaging = FirebaseMessaging.instance;
    
    // Configure Firestore settings
    _firestore!.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  static FirebaseAuth get auth => _auth!;
  static FirebaseFirestore get firestore => _firestore!;
  static FirebaseStorage get storage => _storage!;
  static FirebaseMessaging get messaging => _messaging!;
}