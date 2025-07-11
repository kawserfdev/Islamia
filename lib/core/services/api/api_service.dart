import 'dart:convert';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<dynamic> get(String url) async {
    try {
      print("get url: $url");
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e, stack) {
      print("Network error: $e\n$stack");
      throw Exception('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}