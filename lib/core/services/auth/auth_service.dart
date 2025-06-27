import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:islamia/data/models/auth_result.dart';
import 'package:islamia/data/models/prayer/prayer_notification_settings.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/data/models/user/user_profile.dart';
import '../firebase/firebase_config.dart';
import '../exceptions/service_exception.dart';
import '../user/user_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseConfig.auth;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
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

      // Create user profile
      final userModel = UserModel(
        id: user.uid,
        email: user.email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        preferences: const UserPreferences(
          prayerNotifications: PrayerNotificationSettings(),
        ),
        profile: const UserProfile(),
      );

      await _userService.createUserProfile(userModel);

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: true,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to sign up: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Failed to sign in');
      }

      // Update last login time
      await _userService.updateLastLoginTime(user.uid);

      // Get user profile
      final userModel = await _userService.getUserProfile(user.uid);

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: false,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }

  // Sign in with Google
  // Future<AuthResult> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       throw const AuthException('Google sign in was cancelled');
  //     }

  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final userCredential = await _auth.signInWithCredential(credential);
  //     final user = userCredential.user;
      
  //     if (user == null) {
  //       throw const AuthException('Failed to sign in with Google');
  //     }

  //     final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
  //     UserModel? userModel;

  //     if (isNewUser) {
  //       // Create new user profile
  //       userModel = UserModel(
  //         id: user.uid,
  //         email: user.email,
  //         displayName: user.displayName,
  //         photoURL: user.photoURL,
  //         createdAt: DateTime.now(),
  //         lastLoginAt: DateTime.now(),
  //         preferences: const UserPreferences(
  //           prayerNotifications: PrayerNotificationSettings(),
  //         ),
  //         profile: const UserProfile(),
  //       );
  //       await _userService.createUserProfile(userModel);
  //     } else {
  //       // Get existing user profile
  //       userModel = await _userService.getUserProfile(user.uid);
  //       await _userService.updateLastLoginTime(user.uid);
  //     }

  //     return AuthResult(
  //       user: user,
  //       userModel: userModel,
  //       isNewUser: isNewUser,
  //     );
  //   } catch (e) {
  //     if (e is AuthException) rethrow;
  //     throw AuthException('Failed to sign in with Google: $e');
  //   }
  // }

  // Sign in with Facebook
  Future<AuthResult> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) {
        throw AuthException('Facebook sign in failed: ${result.message}');
      }

      final OAuthCredential credential = 
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

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
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: const UserPreferences(
            prayerNotifications: PrayerNotificationSettings(),
          ),
          profile: const UserProfile(),
        );
        await _userService.createUserProfile(userModel);
      } else {
        userModel = await _userService.getUserProfile(user.uid);
        await _userService.updateLastLoginTime(user.uid);
      }

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: isNewUser,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign in with Facebook: $e');
    }
  }

  // Sign in with phone number
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
        await _userService.createUserProfile(userModel);
      } else {
        userModel = await _userService.getUserProfile(user.uid);
        await _userService.updateLastLoginTime(user.uid);
      }

      return AuthResult(
        user: user,
        userModel: userModel,
        isNewUser: isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to verify phone number: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
       // _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      // Delete user profile from Firestore
      await _userService.deleteUserProfile(user.uid);
      
      // Delete user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }
      
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to update password: $e');
    }
  }

  // Reauthenticate user
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw const AuthException('No user is currently signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to reauthenticate: $e');
    }
  }

  // Get auth error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An authentication error occurred.';
    }
  }
}
