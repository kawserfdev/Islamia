import '../services/exceptions/auth_exception.dart';
import '../services/exceptions/database_exceptions.dart';
import '../services/exceptions/storage_exceptions.dart';
import '../services/exceptions/validation_exceptions.dart';

class ExceptionHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is DatabaseException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is StorageException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unexpected error occurred: $error';
    }
  }

  static bool isNetworkError(dynamic error) {
    return error is NetworkException ||
           (error is Exception && error.toString().contains('network'));
  }

  static bool isAuthError(dynamic error) {
    return error is AuthException;
  }

  static bool isDatabaseError(dynamic error) {
    return error is DatabaseException;
  }

  static bool isValidationError(dynamic error) {
    return error is ValidationException;
  }

  static bool isRetryableError(dynamic error) {
    if (error is NetworkException) {
      return error.statusCode == null || 
             error.statusCode! >= 500 || 
             error.statusCode == 408 || 
             error.statusCode == 429;
    }
    
    if (error is DatabaseException) {
      return error.message.contains('network') || 
             error.message.contains('timeout') ||
             error.message.contains('connection');
    }
    
    return false;
  }

  static Map<String, dynamic> getErrorDetails(dynamic error) {
    return {
      'type': error.runtimeType.toString(),
      'message': getErrorMessage(error),
      'isRetryable': isRetryableError(error),
      'timestamp': DateTime.now().toIso8601String(),
      'originalError': error.toString(),
    };
  }
}