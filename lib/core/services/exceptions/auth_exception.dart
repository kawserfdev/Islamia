import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AuthException(this.message, {this.code, this.originalError});

  factory AuthException.fromFirebaseException(FirebaseAuthException e) {
    return AuthException(
      _getFirebaseErrorMessage(e.code),
      code: e.code,
      originalError: e,
    );
  }

  static String _getFirebaseErrorMessage(String code) {
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
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'provider-already-linked':
        return 'The provider has already been linked to the user account.';
      case 'no-such-provider':
        return 'The user was not linked to the specified provider.';
      case 'invalid-user-token':
        return 'The user\'s credential is no longer valid. The user must sign in again.';
      case 'user-token-expired':
        return 'The user\'s credential has expired. The user must sign in again.';
      case 'null-user':
        return 'A null user object was provided as the argument for an operation which requires a non-null user object.';
      case 'keychain-error':
        return 'A keychain error occurred.';
      case 'internal-error':
        return 'An internal error has occurred.';
      case 'app-deleted':
        return 'This instance of FirebaseApp has been deleted.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      case 'argument-error':
        return 'An invalid argument was provided to a Firebase Authentication method.';
      case 'invalid-api-key':
        return 'Your API key is invalid.';
      case 'network-request-failed':
        return 'A network error has occurred.';
      case 'no-current-user':
        return 'There is no user currently signed in.';
      case 'missing-iframe-start':
        return 'An internal error has occurred.';
      case 'auth-domain-config-required':
        return 'The authDomain configuration is required.';
      case 'cancelled-popup-request':
        return 'The popup request was cancelled.';
      case 'popup-blocked':
        return 'The popup was blocked by the browser.';
      case 'popup-closed-by-user':
        return 'The popup was closed before completing the operation.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for the operation.';
      default:
        return 'An authentication error occurred: ${code.replaceAll('-', ' ')}';
    }
  }

  @override
  String toString() => 'AuthException: $message';
}