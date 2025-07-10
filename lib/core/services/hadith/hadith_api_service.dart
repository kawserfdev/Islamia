import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:islamia/data/models/hadith/hadith_category.dart';
import 'package:islamia/data/models/hadith/hadith_collection.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';

class HadithApiService {
  static const String baseUrl = 'https://api.sunnah.com/v1';
  static const String hadithApiUrl = 'https://hadithapi.com/api';
  
  final http.Client _client;
  final String? _apiKey;

  HadithApiService({http.Client? client, String? apiKey}) 
      : _client = client ?? http.Client(), 
        _apiKey = apiKey;

  // Get all available collections
  Future<List<HadithCollection>> getCollections() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/collections'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> collections = data['data'];
        
        return collections.map((json) => HadithCollection.fromJson(json)).toList();
      } else {
        throw HadithApiException('Failed to fetch collections: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error fetching collections: $e');
    }
  }

  // Get collection details with books
  Future<HadithCollection> getCollection(String collectionId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/collections/$collectionId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HadithCollection.fromJson(data['data']);
      } else {
        throw HadithApiException('Failed to fetch collection: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error fetching collection: $e');
    }
  }

  // Get hadiths from a specific collection
  Future<List<HadithModel>> getHadiths({
    required String collectionId,
    String? bookId,
    String? chapterId,
    int page = 1,
    int limit = 20,
    String language = 'en',
  }) async {
    try {
      final queryParams = {
        'collection': collectionId,
        'page': page.toString(),
        'limit': limit.toString(),
        'lang': language,
        if (bookId != null) 'book': bookId,
        if (chapterId != null) 'chapter': chapterId,
      };

      final uri = Uri.parse('$baseUrl/hadiths').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hadiths = data['data'];
        
        return hadiths.map((json) => _parseHadithFromApi(json)).toList();
      } else {
        throw HadithApiException('Failed to fetch hadiths: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error fetching hadiths: $e');
    }
  }

  // Search hadiths
  Future<List<HadithModel>> searchHadiths({
    required String query,
    String? collectionId,
    String language = 'en',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        'lang': language,
        if (collectionId != null) 'collection': collectionId,
      };

      final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        
        return results.map((json) => _parseHadithFromApi(json)).toList();
      } else {
        throw HadithApiException('Failed to search hadiths: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error searching hadiths: $e');
    }
  }

  // Get hadith by ID
  Future<HadithModel> getHadith(String hadithId, {String language = 'en'}) async {
    try {
      final queryParams = {'lang': language};
      final uri = Uri.parse('$baseUrl/hadiths/$hadithId').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseHadithFromApi(data['data']);
      } else {
        throw HadithApiException('Failed to fetch hadith: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error fetching hadith: $e');
    }
  }

  // Get hadiths by category
  Future<List<HadithModel>> getHadithsByCategory({
    required String category,
    String language = 'en',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'category': category,
        'page': page.toString(),
        'limit': limit.toString(),
        'lang': language,
      };

      final uri = Uri.parse('$baseUrl/categories/$category/hadiths').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hadiths = data['data'];
        
        return hadiths.map((json) => _parseHadithFromApi(json)).toList();
      } else {
        throw HadithApiException('Failed to fetch category hadiths: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error fetching category hadiths: $e');
    }
  }

  // Get random hadith
  Future<HadithModel> getRandomHadith({String language = 'en'}) async {
    try {
      final queryParams = {'lang': language};
      final uri = Uri.parse('$baseUrl/hadiths/random').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseHadithFromApi(data['data']);
      } else {
        throw HadithApiException('Failed to fetch random hadith: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error fetching random hadith: $e');
    }
  }

  // Get available categories
  Future<List<HadithCategory>> getCategories({String language = 'en'}) async {
    try {
      final queryParams = {'lang': language};
      final uri = Uri.parse('$baseUrl/categories').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categories = data['data'];
        
        return categories.map((json) => HadithCategory.fromJson(json)).toList();
      } else {
        throw HadithApiException('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      throw HadithApiException('Error fetching categories: $e');
    }
  }

  // Private helper methods
  Map<String, String> _getHeaders() {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    //API Key
    if (_apiKey != null) {
      headers['X-API-Key'] = _apiKey;
    }
    
    return headers;
  }

  HadithModel _parseHadithFromApi(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'].toString(),
      collection: json['collection']['name'] ?? '',
      book: json['book']['name'] ?? '',
      bookNumber: json['book']['number']?.toString() ?? '',
      hadithNumber: json['hadithNumber']?.toString() ?? '',
      chapter: json['chapter']['title'] ?? '',
      section: json['section']?.toString() ?? '',
      arabicText: json['hadith']['arabic'] ?? '',
      translations: _parseTranslations(json['hadith']),
      narrator: json['hadith']['narrator'] ?? '',
      narratorChain: json['hadith']['chain'] ?? '',
      grade: _parseGrade(json['hadith']['grade']),
      tags: List<String>.from(json['tags'] ?? []),
      topics: List<String>.from(json['topics'] ?? []),
      reference: json['reference'],
      commentary: _parseCommentary(json['commentary']),
    );
  }

  Map<String, String> _parseTranslations(Map<String, dynamic> hadithData) {
    final translations = <String, String>{};
    
    if (hadithData['english'] != null) {
      translations['en'] = hadithData['english'];
    }
    if (hadithData['bengali'] != null) {
      translations['bn'] = hadithData['bengali'];
    }
    if (hadithData['urdu'] != null) {
      translations['ur'] = hadithData['urdu'];
    }
    
    return translations;
  }

  HadithGrade _parseGrade(String? gradeString) {
    if (gradeString == null) return HadithGrade.unknown;
    
    switch (gradeString.toLowerCase()) {
      case 'sahih':
        return HadithGrade.sahih;
      case 'hasan':
        return HadithGrade.hasan;
      case 'daif':
        return HadithGrade.daif;
      case 'maudu':
        return HadithGrade.maudu;
      default:
        return HadithGrade.unknown;
    }
  }

  Map<String, String> _parseCommentary(dynamic commentaryData) {
    if (commentaryData == null) return {};
    if (commentaryData is Map<String, dynamic>) {
      return Map<String, String>.from(commentaryData);
    }
    return {};
  }

  void dispose() {
    _client.close();
  }
}

class HadithApiException implements Exception {
  final String message;
  
  HadithApiException(this.message);
  
  @override
  String toString() => 'HadithApiException: $message';
}
