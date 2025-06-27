// lib/services/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:islamia/core/config/firebase_config.dart';
import 'package:islamia/core/services/exceptions/service_exception.dart';
import 'package:islamia/data/models/auth_result.dart';
import 'package:islamia/data/models/prayer/prayer_notification_settings.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/data/models/user/user_profile.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../user/user_service.dart';
import '../storage/local_storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseConfig.auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();
  final LocalStorageService _localStorage = LocalStorageService();

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get currentUserId => currentUser?.uid;

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Validate inputs
      _validateEmail(email);
      _validatePassword(password);
      _validateDisplayName(displayName);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Failed to create user account');
      }

      // Update display name
      await user.updateDisplayName(displayName);
      await user.reload();

      // Create user model
      final userModel = UserModel(
        id: user.uid,
        email: user.email,
        displayName: displayName,
        isEmailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        preferences: const UserPreferences(
          prayerNotifications: PrayerNotificationSettings(),
        ),
        profile: const UserProfile(),
      );

      // Save to Firestore and local storage
      await _userService.createUser(userModel);

      // Send email verification
      await _sendEmailVerification();

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: true,
        requiresEmailVerification: !user.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign up: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _validateEmail(email);
      _validatePassword(password);

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Failed to sign in');
      }

      // Get or create user profile
      UserModel? userModel = await _userService.getUserById(user.uid);
      
      if (userModel == null) {
        // Create user profile if doesn't exist
        userModel = UserModel(
          id: user.uid,
          email: user.email,
          displayName: user.displayName,
          isEmailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: const UserPreferences(
            prayerNotifications: PrayerNotificationSettings(),
          ),
          profile: const UserProfile(),
        );
        await _userService.createUser(userModel);
      } else {
        // Update last login time
        await _userService.updateLastLoginTime(user.uid);
      }

      // Save auth token locally
      final token = await user.getIdToken();
      await _localStorage.saveAuthToken(token!);

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: false,
        requiresEmailVerification: !user.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign in: $e');
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      UserModel? userModel;

      if (isNewUser) {
        userModel = UserModel(
          id: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          isEmailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: const UserPreferences(
            prayerNotifications: PrayerNotificationSettings(),
          ),
          profile: const UserProfile(),
        );
        await _userService.createUser(userModel);
      } else {
        userModel = await _userService.getUserById(user.uid);
        if (userModel != null) {
          await _userService.updateLastLoginTime(user.uid);
        }
      }

      // Save auth token locally
      final token = await user.getIdToken();
      await _localStorage.saveAuthToken(token!);

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: isNewUser,
        requiresEmailVerification: false,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  // Sign in with Apple
  Future<AuthResult> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      
      if (user == null) {
        throw const AuthException('Failed to sign in with Apple');
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      UserModel? userModel;

      if (isNewUser) {
        String? displayName;
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        }

        userModel = UserModel(
          id: user.uid,
          email: user.email ?? appleCredential.email,
          displayName: displayName ?? user.displayName,
          isEmailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: const UserPreferences(
            prayerNotifications: PrayerNotificationSettings(),
          ),
          profile: const UserProfile(),
        );
        await _userService.createUser(userModel);
      } else {
        userModel = await _userService.getUserById(user.uid);
        if (userModel != null) {
          await _userService.updateLastLoginTime(user.uid);
        }
      }

      // Save auth token locally
      final token = await user.getIdToken();
      await _localStorage.saveAuthToken(token!);

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: isNewUser,
        requiresEmailVerification: false,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign in with Apple: $e');
    }
  }

  // Sign in with Facebook
  Future<AuthResult> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) {
        throw AuthException('Facebook sign in failed: ${result.message}');
      }

      final OAuthCredential credential = 
          FacebookAuthProvider.credential(result.accessToken!.token);

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw const AuthException('Failed to sign in with Facebook');
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      UserModel? userModel;

      if (isNewUser) {
        userModel = UserModel(
          id: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          isEmailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: const UserPreferences(
            prayerNotifications: PrayerNotificationSettings(),
          ),
          profile: const UserProfile(),
        );
        await _userService.createUser(userModel);
      } else {
        userModel = await _userService.getUserById(user.uid);
        if (userModel != null) {
          await _userService.updateLastLoginTime(user.uid);
        }
      }

      // Save auth token locally
      final token = await user.getIdToken();
      await _localStorage.saveAuthToken(token!);

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: isNewUser,
        requiresEmailVerification: false,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign in with Facebook: $e');
    }
  }

  // Phone number authentication
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw AuthException('Failed to verify phone number: $e');
    }
  }

  // Verify phone number with SMS code
  Future<AuthResult> verifyPhoneNumberWithCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw const AuthException('Failed to verify phone number');
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      UserModel? userModel;

      if (isNewUser) {
        userModel = UserModel(
          id: user.uid,
          phoneNumber: user.phoneNumber,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: const UserPreferences(
            prayerNotifications: PrayerNotificationSettings(),
          ),
          profile: const UserProfile(),
        );
        await _userService.createUser(userModel);
      } else {
        userModel = await _userService.getUserById(user.uid);
        if (userModel != null) {
          await _userService.updateLastLoginTime(user.uid);
        }
      }

      // Save auth token locally
      final token = await user.getIdToken();
      await _localStorage.saveAuthToken(token!);

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: isNewUser,
        requiresEmailVerification: false,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      throw AuthException('Failed to verify phone number: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    await _sendEmailVerification();
  }

  Future<void> _sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      throw AuthException('Failed to send email verification: $e');
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      await user.reload();
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _validateEmail(email);
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }
      
      _validatePassword(newPassword);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      throw AuthException('Failed to update password: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);

      // Clear local storage
      await _localStorage.deleteUser();
      await _localStorage.deleteAuthToken();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      // Delete user data from Firestore and local storage
      await _userService.deleteUser(user.uid);
      
      // Delete user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.toString());
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  // Get stored auth token
  Future<String?> getStoredAuthToken() async {
    return await _localStorage.getAuthToken();
  }

  // Check if user is logged in locally
  Future<bool> isLoggedInLocally() async {
    return await _localStorage.isLoggedIn();
  }

  // Validation methods
  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw const AuthException('Email cannot be empty');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw const AuthException('Invalid email format');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw const AuthException('Password cannot be empty');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters');
    }
  }

  void _validateDisplayName(String displayName) {
    if (displayName.isEmpty) {
      throw const AuthException('Display name cannot be empty');
    }
    if (displayName.length < 2) {
      throw const AuthException('Display name must be at least 2 characters');
    }
  }
}