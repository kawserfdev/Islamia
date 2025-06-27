// models/api_response.dart
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final Map<String, dynamic>? rawData;
  final String? message;
  final bool success;

  const ApiResponse({
    required this.statusCode,
    this.data,
    this.rawData,
    this.message,
    required this.success,
  });

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !success || statusCode >= 400;
}