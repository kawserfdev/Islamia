class StorageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const StorageException(this.message, {this.code, this.originalError});

  factory StorageException.fromFirebaseStorage(dynamic error) {
    if (error is Exception) {
      return StorageException(
        'Firebase Storage error: ${error.toString()}',
        originalError: error,
      );
    }
    return StorageException('Firebase Storage error: $error', originalError: error);
  }

  factory StorageException.fileNotFound() {
    return const StorageException('File not found');
  }

  factory StorageException.permissionDenied() {
    return const StorageException('Permission denied');
  }

  factory StorageException.quotaExceeded() {
    return const StorageException('Storage quota exceeded');
  }

  @override
  String toString() => 'StorageException: $message';
}
