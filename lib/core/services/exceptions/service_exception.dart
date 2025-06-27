class ServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const ServiceException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'ServiceException: $message';
}

class AuthException extends ServiceException {
  const AuthException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class NetworkException extends ServiceException {
  const NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ValidationException extends ServiceException {
  const ValidationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}