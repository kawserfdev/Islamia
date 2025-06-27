class ValidationException implements Exception {
  final String message;
  final String? field;
  final dynamic value;

  const ValidationException(this.message, {this.field, this.value});

  factory ValidationException.required(String field) {
    return ValidationException('$field is required', field: field);
  }

  factory ValidationException.invalidFormat(String field, {String? expectedFormat}) {
    final formatInfo = expectedFormat != null ? ' Expected format: $expectedFormat' : '';
    return ValidationException('$field has invalid format.$formatInfo', field: field);
  }

  factory ValidationException.tooShort(String field, int minLength) {
    return ValidationException('$field must be at least $minLength characters', field: field);
  }

  factory ValidationException.tooLong(String field, int maxLength) {
    return ValidationException('$field must not exceed $maxLength characters', field: field);
  }

  factory ValidationException.outOfRange(String field, {num? min, num? max}) {
    String range = '';
    if (min != null && max != null) {
      range = ' Must be between $min and $max';
    } else if (min != null) {
      range = ' Must be at least $min';
    } else if (max != null) {
      range = ' Must not exceed $max';
    }
    return ValidationException('$field is out of range.$range', field: field);
  }

  @override
  String toString() => 'ValidationException: $message';
}