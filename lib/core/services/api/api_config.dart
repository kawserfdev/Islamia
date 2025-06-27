class ApiConfig {
  static const String baseUrl = 'https://your-api-base-url.com/api';
  static const String version = 'v1';
  static const Duration timeout = Duration(seconds: 30);
  
  // API Endpoints
  static const String usersEndpoint = '/users';
  static const String authEndpoint = '/auth';
  static const String uploadEndpoint = '/upload';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}