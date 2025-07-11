import 'dart:convert';
import 'dart:io';
import 'package:islamia/data/models/api_response.dart';
import '../exceptions/service_exception.dart';
import 'api_config.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> multipartRequest<T>(
    String method,
    String endpoint, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest(method, uri);
      
      request.headers.addAll(_headers);
      
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final path = '${ApiConfig.baseUrl}/${ApiConfig.version}$endpoint';
    return Uri.parse(path).replace(queryParameters: queryParameters);
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      T? parsedData;
      if (fromJson != null && data.containsKey('data')) {
        parsedData = fromJson(data['data']);
      }
      
      return ApiResponse<T>(
        statusCode: statusCode,
        data: parsedData,
        rawData: data,
        message: data['message'],
        success: true,
      );
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return ApiResponse<T>(
        statusCode: statusCode,
        rawData: errorData,
        message: errorData['message'] ?? 'Request failed',
        success: false,
      );
    }
  }

  ServiceException _handleError(dynamic error) {
    if (error is SocketException) {
      return const NetworkException('No internet connection');
    } else if (error is http.ClientException) {
      return NetworkException('Network error: ${error.message}');
    } else {
      return ServiceException('Unexpected error: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}