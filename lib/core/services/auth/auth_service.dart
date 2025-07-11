// // lib/services/auth/auth_service.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:islamia/core/config/firebase_config.dart';
// import 'package:islamia/core/services/exceptions/service_exception.dart';
// import 'package:islamia/data/models/auth_result.dart';
// import 'package:islamia/data/models/prayer/prayer_notification_settings.dart';
// import 'package:islamia/data/models/user/user_model.dart';
// import 'package:islamia/data/models/user/user_profile.dart';
// //import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import '../user/user_service.dart';
// import '../storage/local_storage_service.dart';

// class AuthService {
//   static final AuthService _instance = AuthService._internal();
//   factory AuthService() => _instance;
//   AuthService._internal();

//   final FirebaseAuth _auth = FirebaseConfig.auth;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final UserService _userService = UserService();
//   final LocalStorageService _localStorage = LocalStorageService();

//   // Current user stream
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//   User? get currentUser => _auth.currentUser;
//   bool get isAuthenticated => currentUser != null;
//   String? get currentUserId => currentUser?.uid;

//   // Sign up with email and password
//   Future<AuthResult> signUpWithEmailAndPassword({
//     required String email,
//     required String password,
//     required String displayName,
//   }) async {
//     try {
//       // Validate inputs
//       _validateEmail(email);
//       _validatePassword(password);
//       _validateDisplayName(displayName);

//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = userCredential.user;
//       if (user == null) {
//         throw const AuthException('Failed to create user account');
//       }

//       // Update display name
//       await user.updateDisplayName(displayName);
//       await user.reload();

//       // Create user model
//       final userModel = UserModel(
//         id: user.uid,
//         email: user.email,
//         displayName: displayName,
//         isEmailVerified: user.emailVerified,
//         createdAt: DateTime.now(),
//         lastLoginAt: DateTime.now(),
//         preferences: const UserPreferences(
//           prayerNotifications: PrayerNotificationSettings(),
//         ),
//         profile: const UserProfile(),
//       );

//       // Save to Firestore and local storage
//       await _userService.createUser(userModel);

//       // Send email verification
//       await _sendEmailVerification();

//       return AuthResult(
//         user: user,
//         userModel: userModel,
//         isNewUser: true,
//         requiresEmailVerification: !user.emailVerified,
//       );
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(e.toString());
//     } catch (e) {
//       if (e is AuthException) rethrow;
//       throw AuthException('Failed to sign up: $e');
//     }
//   }

//   // Sign in with email and password
//   Future<AuthResult> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       _validateEmail(email);
//       _validatePassword(password);

//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = userCredential.user;
//       if (user == null) {
//         throw const AuthException('Failed to sign in');
//       }

//       // Get or create user profile
//       UserModel? userModel = await _userService.getUserById(user.uid);
      
//       if (userModel == null) {
//         // Create user profile if doesn't exist
//         userModel = UserModel(
//           id: user.uid,
//           email: user.email,
//           displayName: user.displayName,
//           isEmailVerified: user.emailVerified,
//           createdAt: DateTime.now(),
//           lastLoginAt: DateTime.now(),
//           preferences: const UserPreferences(
//             prayerNotifications: PrayerNotificationSettings(),
//           ),
//           profile: const UserProfile(),
//         );
//         await _userService.createUser(userModel);
//       } else {
//         // Update last login time
//         await _userService.updateLastLoginTime(user.uid);
//       }

//       // Save auth token locally
//       final token = await user.getIdToken();
//       await _localStorage.saveAuthToken(token!);

//       return AuthResult(
//         user: user,
//         userModel: userModel,
//         isNewUser: false,
//         requiresEmailVerification: !user.emailVerified,
//       );
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(e.toString());
//     } catch (e) {
//       if (e is AuthException) rethrow;
//       throw AuthException('Failed to sign in: $e');
//     }
//   }

//   // Sign in with Google
//   Future<AuthResult> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         throw const AuthException('Google sign in was cancelled');
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       final user = userCredential.user;
      
//       if (user == null) {
//         throw const AuthException('Failed to sign in with Google');
//       }

//       final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
//       UserModel? userModel;

//       if (isNewUser) {
//         userModel = UserModel(
//           id: user.uid,
//           email: user.email,
//           displayName: user.displayName,
//           photoURL: user.photoURL,
//           isEmailVerified: user.emailVerified,
//           createdAt: DateTime.now(),
//           lastLoginAt: DateTime.now(),
//           preferences: const UserPreferences(
//             prayerNotifications: PrayerNotificationSettings(),
//           ),
//           profile: const UserProfile(),
//         );
//         await _userService.createUser(userModel);
//       } else {
//         userModel = await _userService.getUserById(user.uid);
//         if (userModel != null) {
//           await _userService.updateLastLoginTime(user.uid);
//         }
//       }

//       // Save auth token locally
//       final token = await user.getIdToken();
//       await _localStorage.saveAuthToken(token!);

//       return AuthResult(
//         user: user,
//         userModel: userModel,
//         isNewUser: isNewUser,
//         requiresEmailVerification: false,
//       );
//     } catch (e) {
//       if (e is AuthException) rethrow;
//       throw AuthException('Failed to sign in with Google: $e');
//     }
//   }

//   // Sign in with Apple
//   // Future<AuthResult> signInWithApple() async {
//   //   try {
//   //     final appleCredential = await SignInWithApple.getAppleIDCredential(
//   //       scopes: [
//   //         AppleIDAuthorizationScopes.email,
//   //         AppleIDAuthorizationScopes.fullName,
//   //       ],
//   //     );

//   //     final oauthCredential = OAuthProvider("apple.com").credential(
//   //       idToken: appleCredential.identityToken,
//   //       accessToken: appleCredential.authorizationCode,
//   //     );

//   //     final userCredential = await _auth.signInWithCredential(oauthCredential);
//   //     final user = userCredential.user;
      
//   //     if (user == null) {
//   //       throw const AuthException('Failed to sign in with Apple');
//   //     }

//   //     final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
//   //     UserModel? userModel;

//   //     if (isNewUser) {
//   //       String? displayName;
//   //       if (appleCredential.givenName != null || appleCredential.familyName != null) {
//   //         displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
//   //       }

//   //       userModel = UserModel(
//   //         id: user.uid,
//   //         email: user.email ?? appleCredential.email,
//   //         displayName: displayName ?? user.displayName,
//   //         isEmailVerified: user.emailVerified,
//   //         createdAt: DateTime.now(),
//   //         lastLoginAt: DateTime.now(),
//   //         preferences: const UserPreferences(
//   //           prayerNotifications: PrayerNotificationSettings(),
//   //         ),
//   //         profile: const UserProfile(),
//   //       );
//   //       await _userService.createUser(userModel);
//   //     } else {
//   //       userModel = await _userService.getUserById(user.uid);
//   //       if (userModel != null) {
//   //         await _userService.updateLastLoginTime(user.uid);
//   //       }
//   //     }

//   //     // Save auth token locally
//   //     final token = await user.getIdToken();
//   //     await _localStorage.saveAuthToken(token!);

//   //     return AuthResult(
//   //       user: user,
//   //       userModel: userModel,
//   //       isNewUser: isNewUser,
//   //       requiresEmailVerification: false,
//   //     );
//   //   } catch (e) {
//   //     if (e is AuthException) rethrow;
//   //     throw AuthException('Failed to sign in with Apple: $e');
//   //   }
//   // }

//   // Sign in with Facebook
//   Future<AuthResult> signInWithFacebook() async {
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
      
//       if (result.status != LoginStatus.success) {
//         throw AuthException('Facebook sign in failed: ${result.message}');
//       }

//       final OAuthCredential credential = 
//           FacebookAuthProvider.credential(result.accessToken!.token);

//       final userCredential = await _auth.signInWithCredential(credential);
//       final user = userCredential.user;
      
//       if (user == null) {
//         throw const AuthException('Failed to sign in with Facebook');
//       }

//       final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
//       UserModel? userModel;

//       if (isNewUser) {
//         userModel = UserModel(
//           id: user.uid,
//           email: user.email,
//           displayName: user.displayName,
//           photoURL: user.photoURL,
//           isEmailVerified: user.emailVerified,
//           createdAt: DateTime.now(),
//           lastLoginAt: DateTime.now(),
//           preferences: const UserPreferences(
//             prayerNotifications: PrayerNotificationSettings(),
//           ),
//           profile: const UserProfile(),
//         );
//         await _userService.createUser(userModel);
//       } else {
//         userModel = await _userService.getUserById(user.uid);
//         if (userModel != null) {
//           await _userService.updateLastLoginTime(user.uid);
//         }
//       }

//       // Save auth token locally
//       final token = await user.getIdToken();
//       await _localStorage.saveAuthToken(token!);

//       return AuthResult(
//         user: user,
//         userModel: userModel,
//         isNewUser: isNewUser,
//         requiresEmailVerification: false,
//       );
//     } catch (e) {
//       if (e is AuthException) rethrow;
//       throw AuthException('Failed to sign in with Facebook: $e');
//     }
//   }

//   // Phone number authentication
//   Future<void> signInWithPhoneNumber({
//     required String phoneNumber,
//     required Function(PhoneAuthCredential) verificationCompleted,
//     required Function(FirebaseAuthException) verificationFailed,
//     required Function(String, int?) codeSent,
//     required Function(String) codeAutoRetrievalTimeout,
//   }) async {
//     try {
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: verificationCompleted,
//         verificationFailed: verificationFailed,
//         codeSent: codeSent,
//         codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
//         timeout: const Duration(seconds: 60),
//       );
//     } catch (e) {
//       throw AuthException('Failed to verify phone number: $e');
//     }
//   }

//   // Verify phone number with SMS code
//   Future<AuthResult> verifyPhoneNumberWithCode({
//     required String verificationId,
//     required String smsCode,
//   }) async {
//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: smsCode,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       final user = userCredential.user;
      
//       if (user == null) {
//         throw const AuthException('Failed to verify phone number');
//       }

//       final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
//       UserModel? userModel;

//       if (isNewUser) {
//         userModel = UserModel(
//           id: user.uid,
//           phoneNumber: user.phoneNumber,
//           createdAt: DateTime.now(),
//           lastLoginAt: DateTime.now(),
//           preferences: const UserPreferences(
//             prayerNotifications: PrayerNotificationSettings(),
//           ),
//           profile: const UserProfile(),
//         );
//         await _userService.createUser(userModel);
//       } else {
//         userModel = await _userService.getUserById(user.uid);
//         if (userModel != null) {
//           await _userService.updateLastLoginTime(user.uid);
//         }
//       }

//       // Save auth token locally
//       final token = await user.getIdToken();
//       await _localStorage.saveAuthToken(token!);

//       return AuthResult(
//         user: user,
//         userModel: userModel,
//         isNewUser: isNewUser,
//         requiresEmailVerification: false,
//       );
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(e.toString());
//     } catch (e) {
//       throw AuthException('Failed to verify phone number: $e');
//     }
//   }

//   // Send email verification
//   Future<void> sendEmailVerification() async {
//     await _sendEmailVerification();
//   }

//   Future<void> _sendEmailVerification() async {
//     try {
//       final user = currentUser;
//       if (user == null) {
//         throw const AuthException('No user is currently signed in');
//       }

//       if (!user.emailVerified) {
//         await user.sendEmailVerification();
//       }
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(e.toString());
//     } catch (e) {
//       throw AuthException('Failed to send email verification: $e');
//     }
//   }

//   // Check email verification status
//   Future<bool> checkEmailVerification() async {
//     try {
//       final user = currentUser;
//       if (user == null) return false;

//       await user.reload();
//       return user.emailVerified;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Send password reset email
//   Future<void> sendPasswordResetEmail(String email) async {
//     try {
//       _validateEmail(email);
//       await _auth.sendPasswordResetEmail(email: email);
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(e.toString());
//     } catch (e) {
//       throw AuthException('Failed to send password reset email: $e');
//     }
//   }

//   // Update password
//   Future<void> updatePassword(String newPassword) async {
//     try {
//       final user = currentUser;
//       if (user == null) {
//         throw const AuthException('No user is currently signed in');
//       }
      
//       _validatePassword(newPassword);
//       await user.updatePassword(newPassword);
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(e.toString());
//     } catch (e) {
//       throw AuthException('Failed to update password: $e');
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     try {
//       await Future.wait([
//         _auth.signOut(),
//         _googleSignIn.signOut(),
//         FacebookAuth.instance.logOut(),
//       ]);

//       // Clear local storage
//       await _localStorage.deleteUser();
//       await _localStorage.deleteAuthToken();
//     } catch (e) {
//       throw AuthException('Failed to sign out: $e');
//     }
//   }

//   // Delete user account
//   Future<void> deleteAccount() async {
//     try {
//       final user = currentUser;
//       if (user == null) {
//         throw const AuthException('No user is currently signed in');
//       }

//       // Delete user data from Firestore and local storage
//       await _userService.deleteUser(user.uid);
      
//       // Delete user account
//       await user.delete();
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(e.toString());
//     } catch (e) {
//       throw AuthException('Failed to delete account: $e');
//     }
//   }

//   // Get stored auth token
//   Future<String?> getStoredAuthToken() async {
//     return await _localStorage.getAuthToken();
//   }

//   // Check if user is logged in locally
//   Future<bool> isLoggedInLocally() async {
//     return await _localStorage.isLoggedIn();
//   }

//   // Validation methods
//   void _validateEmail(String email) {
//     if (email.isEmpty) {
//       throw const AuthException('Email cannot be empty');
//     }
//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
//       throw const AuthException('Invalid email format');
//     }
//   }

//   void _validatePassword(String password) {
//     if (password.isEmpty) {
//       throw const AuthException('Password cannot be empty');
//     }
//     if (password.length < 6) {
//       throw const AuthException('Password must be at least 6 characters');
//     }
//   }

//   void _validateDisplayName(String displayName) {
//     if (displayName.isEmpty) {
//       throw const AuthException('Display name cannot be empty');
//     }
//     if (displayName.length < 2) {
//       throw const AuthException('Display name must be at least 2 characters');
//     }
//   }
// }
















import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:islamia/data/models/user/user_profile.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import '../models/user/user_profile.dart';
import '../database/user_database.dart';
import 'cloud_sync_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final UserDatabase _userDatabase = UserDatabase();
  final CloudSyncService _cloudSync = CloudSyncService();

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Initialize authentication
  Future<void> initialize() async {
    // Check for biometric authentication setup
    await _setupBiometricAuth();
    
    // Listen to auth state changes
    authStateChanges.listen(_onAuthStateChanged);
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      // Validate input
      _validateEmail(email);
      _validatePassword(password);

      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to create user account');
      }

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Create user profile
      final userProfile = UserProfile(
        id: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        displayName: '$firstName $lastName',
        statistics: UserStatistics(
          prayerStats: PrayerStatistics(),
          readingStats: ReadingStatistics(),
        ),
        preferences: _createDefaultPreferences(),
        privacySettings: _createDefaultPrivacySettings(),
        createdAt: DateTime.now(),
        accountType: AccountType.individual,
      );

      // Save to local database
      await _userDatabase.insertUserProfile(userProfile);

      // Sync to cloud
      await _cloudSync.syncUserProfile(userProfile);

      // Create user session
      await _createUserSession(userProfile.id);

      return AuthResult.success(userProfile);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _validateEmail(email);
      
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Invalid credentials');
      }

      // Get user profile
      var userProfile = await _userDatabase.getUserProfile(userCredential.user!.uid);
      
      if (userProfile == null) {
        // Create profile from Firebase user data
        userProfile = await _createProfileFromFirebaseUser(userCredential.user!);
        await _userDatabase.insertUserProfile(userProfile);
      }

      // Update last login
      await _userDatabase.updateLastLogin(userProfile.id);
      await _cloudSync.updateLastLogin(userProfile.id);

      // Create user session
      await _createUserSession(userProfile.id);

      // Sync data from cloud
      await _cloudSync.syncFromCloud(userProfile.id);

      return AuthResult.success(userProfile);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Sign in failed: $e');
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Start Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult.failure('Google sign in was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return AuthResult.failure('Google sign in failed');
      }

      // Check if user exists
      var userProfile = await _userDatabase.getUserProfile(userCredential.user!.uid);
      
      if (userProfile == null) {
        // Create new profile
        userProfile = await _createProfileFromFirebaseUser(userCredential.user!);
        await _userDatabase.insertUserProfile(userProfile);
        await _cloudSync.syncUserProfile(userProfile);
      } else {
        // Update last login
        await _userDatabase.updateLastLogin(userProfile.id);
        await _cloudSync.updateLastLogin(userProfile.id);
      }

      // Create user session
      await _createUserSession(userProfile.id);

      return AuthResult.success(userProfile);
    } catch (e) {
      return AuthResult.failure('Google sign in failed: $e');
    }
  }

  // Sign in with phone number
  Future<AuthResult> signInWithPhone(String phoneNumber) async {
    try {
      final completer = Completer<AuthResult>();
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _firebaseAuth.signInWithCredential(credential);
          
          if (userCredential.user != null) {
            var userProfile = await _userDatabase.getUserProfile(userCredential.user!.uid);
            
            if (userProfile == null) {
              userProfile = await _createProfileFromFirebaseUser(userCredential.user!);
              await _userDatabase.insertUserProfile(userProfile);
            }
            
            await _createUserSession(userProfile.id);
            completer.complete(AuthResult.success(userProfile));
          } else {
            completer.complete(AuthResult.failure('Phone verification failed'));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.complete(AuthResult.failure(_getFirebaseErrorMessage(e)));
        },
        codeSent: (String verificationId, int? resendToken) {
          // You would handle OTP verification here
          // This is a simplified implementation
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );

      return await completer.future;
    } catch (e) {
      return AuthResult.failure('Phone sign in failed: $e');
    }
  }

  // Sign in as guest
  Future<AuthResult> signInAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();

      if (userCredential.user == null) {
        return AuthResult.failure('Guest sign in failed');
      }

      // Create guest profile
      final userProfile = UserProfile(
        id: userCredential.user!.uid,
        displayName: 'Guest User',
        statistics: UserStatistics(
          prayerStats: PrayerStatistics(),
          readingStats: ReadingStatistics(),
        ),
        preferences: _createDefaultPreferences(),
        privacySettings: _createDefaultPrivacySettings(),
        createdAt: DateTime.now(),
        accountType: AccountType.guest,
      );

      await _userDatabase.insertUserProfile(userProfile);
      await _createUserSession(userProfile.id);

      return AuthResult.success(userProfile);
    } catch (e) {
      return AuthResult.failure('Guest sign in failed: $e');
    }
  }

  // Biometric authentication
  Future<AuthResult> signInWithBiometrics() async {
    try {
      // Check if biometrics are available
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return AuthResult.failure('Biometric authentication not available');
      }

      // Check if biometrics are enrolled
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return AuthResult.failure('No biometric methods enrolled');
      }

      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Islamia',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        return AuthResult.failure('Biometric authentication failed');
      }

      // Get stored user credentials (you'd implement secure storage)
      final storedCredentials = await _getStoredCredentials();
      if (storedCredentials == null) {
        return AuthResult.failure('No stored credentials found');
      }

      // Sign in with stored credentials
      return await signInWithEmail(
        email: storedCredentials['email']!,
        password: storedCredentials['password']!,
      );
    } catch (e) {
      return AuthResult.failure('Biometric sign in failed: $e');
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      _validateEmail(email);
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email: $e');
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('User not authenticated');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      return AuthResult.success(null, message: 'Password updated successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to change password: $e');
    }
  }

  // Update email
  Future<AuthResult> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('User not authenticated');
      }

      _validateEmail(newEmail);
      
      await user.updateEmail(newEmail);
      await user.sendEmailVerification();
      
      // Update local profile
      final profile = await _userDatabase.getUserProfile(user.uid);
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          email: newEmail,
          isVerified: false,
          updatedAt: DateTime.now(),
        );
        await _userDatabase.updateUserProfile(updatedProfile);
        await _cloudSync.syncUserProfile(updatedProfile);
      }
      
      return AuthResult.success(null, message: 'Email updated successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to update email: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Deactivate current session
      if (currentUser != null) {
        // Implementation depends on how you track sessions
      }

      // Sign out from all providers
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('User not authenticated');
      }

      // Re-authenticate user
      if (user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Delete user data
      await _userDatabase.deleteUserData(user.uid);
      await _cloudSync.deleteUserData(user.uid);

      // Delete Firebase account
      await user.delete();

      return AuthResult.success(null, message: 'Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to delete account: $e');
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    
    return await _userDatabase.getUserProfile(user.uid);
  }

  // Update user profile
  Future<AuthResult> updateUserProfile(UserProfile profile) async {
    try {
      await _userDatabase.updateUserProfile(profile);
      await _cloudSync.syncUserProfile(profile);
      return AuthResult.success(profile);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: $e');
    }
  }

  // Private helper methods
  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      // User signed in
      await _userDatabase.updateLastLogin(user.uid);
    }
  }

  Future<UserProfile> _createProfileFromFirebaseUser(User user) async {
    final nameParts = user.displayName?.split(' ') ?? [];
    
    return UserProfile(
      id: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      firstName: nameParts.isNotEmpty ? nameParts.first : null,
      lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : null,
      photoURL: user.photoURL,
      isVerified: user.emailVerified,
      statistics: UserStatistics(
        prayerStats: PrayerStatistics(),
        readingStats: ReadingStatistics(),
      ),
      preferences: _createDefaultPreferences(),
      privacySettings: _createDefaultPrivacySettings(),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  UserPreferences _createDefaultPreferences() {
    return UserPreferences(
      notifications: NotificationPreferences(),
      audio: AudioPreferences(),
      display: DisplayPreferences(),
      privacy: PrivacyPreferences(),
      location: LocationPreferences(),
      backup: BackupPreferences(),
      accessibility: AccessibilityPreferences(),
    );
  }

  PrivacySettings _createDefaultPrivacySettings() {
    return PrivacySettings();
  }

  Future<void> _createUserSession(String userId) async {
    await _userDatabase.createUserSession(
      userId: userId,
      deviceId: await _getDeviceId(),
      deviceName: await _getDeviceName(),
      platform: Platform.operatingSystem,
      appVersion: '1.0.0', // Get from package info
    );
  }

  Future<void> _setupBiometricAuth() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (isAvailable && isDeviceSupported) {
        // Biometric authentication is available
        // You can store this information in preferences
      }
    } catch (e) {
      print('Biometric setup error: $e');
    }
  }

  Future<Map<String, String>?> _getStoredCredentials() async {
    // Implement secure storage for credentials
    // This is a placeholder - use flutter_secure_storage in production
    return null;
  }

  Future<String> _getDeviceId() async {
    // Implement device ID generation
    // Use device_info_plus package
    return 'device_id_placeholder';
  }

  Future<String> _getDeviceName() async {
    // Implement device name retrieval
    // Use device_info_plus package
    return 'Device Name';
  }

  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw ArgumentError('Invalid email format');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters long');
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      throw ArgumentError('Password must contain at least one uppercase letter, one lowercase letter, and one number');
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

// Authentication result class
class AuthResult {
  final bool isSuccess;
  final UserProfile? user;
  final String? error;
  final String? message;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResult.success(UserProfile? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}