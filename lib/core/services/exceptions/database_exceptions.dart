class DatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DatabaseException(this.message, {this.code, this.originalError});

  factory DatabaseException.fromFirestore(dynamic error) {
    if (error is Exception) {
      return DatabaseException(
        'Firestore error: ${error.toString()}',
        originalError: error,
      );
    }
    return DatabaseException('Firestore error: $error', originalError: error);
  }

  factory DatabaseException.fromSQLite(dynamic error) {
    if (error is Exception) {
      return DatabaseException(
        'SQLite error: ${error.toString()}',
        originalError: error,
      );
    }
    return DatabaseException('SQLite error: $error', originalError: error);
  }

  factory DatabaseException.fromSharedPreferences(dynamic error) {
    if (error is Exception) {
      return DatabaseException(
        'SharedPreferences error: ${error.toString()}',
        originalError: error,
      );
    }
    return DatabaseException('SharedPreferences error: $error', originalError: error);
  }

  @override
  String toString() => 'DatabaseException: $message';
}

// lib/services/exceptions/network_exceptions.dart
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const NetworkException(this.message, {this.statusCode, this.originalError});

  factory NetworkException.fromHttpError(int statusCode, String? reasonPhrase) {
    String message;
    switch (statusCode) {
      case 400:
        message = 'Bad request';
        break;
      case 401:
        message = 'Unauthorized';
        break;
      case 403:
        message = 'Forbidden';
        break;
      case 404:
        message = 'Not found';
        break;
      case 408:
        message = 'Request timeout';
        break;
      case 429:
        message = 'Too many requests';
        break;
      case 500:
        message = 'Internal server error';
        break;
      case 502:
        message = 'Bad gateway';
        break;
      case 503:
        message = 'Service unavailable';
        break;
      case 504:
        message = 'Gateway timeout';
        break;
      default:
        message = reasonPhrase ?? 'Unknown error';
    }
    
    return NetworkException(
      message,
      statusCode: statusCode,
    );
  }

  factory NetworkException.noInternet() {
    return const NetworkException('No internet connection');
  }

  factory NetworkException.timeout() {
    return const NetworkException('Request timeout');
  }

  @override
  String toString() => 'NetworkException: $message';
}