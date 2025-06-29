import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:islamia/data/models/quran/audio_recitation_model.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import 'package:islamia/data/models/quran/reciter_model.dart';
import 'package:islamia/data/models/quran/surah_model.dart';

class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  static const String quranComUrl = 'https://api.quran.com/api/v4';

  final http.Client _client;

  QuranApiService({http.Client? client}) : _client = client ?? http.Client();

  // Get all Surahs using your SurahModel
  Future<List<SurahModel>> getSurahs({String language = 'en'}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/surah'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahList = data['data'];

        return surahList.map((json) => SurahModel.fromJson(json)).toList();
      } else {
        throw QuranApiException(
          'Failed to fetch surahs: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw QuranApiException('Error fetching surahs: $e');
    }
  }

  // Get specific Surah with Ayahs
  Future<SurahWithAyahs> getSurah(
    int surahNumber, {
    String translation = 'en.sahih',
    String reciter = 'ar.alafasy',
  }) async {
    try {
      // Fetch Arabic text
      final arabicResponse = await _client.get(
        Uri.parse('$baseUrl/surah/$surahNumber'),
      );

      // Fetch translation
      final translationResponse = await _client.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$translation'),
      );

      if (arabicResponse.statusCode == 200 &&
          translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);

        return SurahWithAyahs.fromApiResponse(
          arabicData['data'],
          translationData['data'],
        );
      } else {
        throw QuranApiException('Failed to fetch surah');
      }
    } catch (e) {
      throw QuranApiException('Error fetching surah: $e');
    }
  }

  // Get specific Ayah
  Future<AyahModel> getAyah(
    int surahNumber,
    int ayahNumber, {
    String translation = 'en.sahih',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$baseUrl/ayah/$surahNumber:$ayahNumber/editions/quran-uthmani,$translation',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AyahModel.fromJson(data['data']);
      } else {
        throw QuranApiException('Failed to fetch ayah');
      }
    } catch (e) {
      throw QuranApiException('Error fetching ayah: $e');
    }
  }

  // Search Quran
  Future<List<SearchResult>> searchQuran(
    String query, {
    String translation = 'en.sahih',
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/search/$query/all/$translation'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data']['matches'];

        return results
            .take(limit)
            .map((json) => SearchResult.fromJson(json))
            .toList();
      } else {
        throw QuranApiException('Failed to search Quran');
      }
    } catch (e) {
      throw QuranApiException('Error searching Quran: $e');
    }
  }

  // Get available reciters
  Future<List<ReciterModel>> getReciters() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/edition/type/audio'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reciters = data['data'];

        return reciters.map((json) => ReciterModel.fromJson(json)).toList();
      } else {
        throw QuranApiException('Failed to fetch reciters');
      }
    } catch (e) {
      throw QuranApiException('Error fetching reciters: $e');
    }
  }

  // Get audio for specific ayah
  Future<AudioRecitationModel> getAyahAudio(
    int surahNumber,
    int ayahNumber,
    String reciterId,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ayah/$surahNumber:$ayahNumber/$reciterId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AudioRecitationModel.fromApiResponse(data['data']);
      } else {
        throw QuranApiException('Failed to fetch audio');
      }
    } catch (e) {
      throw QuranApiException('Error fetching audio: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

// Custom exception for API errors
class QuranApiException implements Exception {
  final String message;

  QuranApiException(this.message);

  @override
  String toString() => 'QuranApiException: $message';
}

// Supporting models for API responses
class SurahWithAyahs {
  final SurahModel surah;
  final List<AyahModel> ayahs;

  SurahWithAyahs({required this.surah, required this.ayahs});

  factory SurahWithAyahs.fromApiResponse(
    Map<String, dynamic> arabicData,
    Map<String, dynamic> translationData,
  ) {
    final surah = SurahModel.fromJson(arabicData);
    final arabicAyahs = arabicData['ayahs'] as List;
    final translationAyahs = translationData['ayahs'] as List;

    final ayahs = <AyahModel>[];
    for (int i = 0; i < arabicAyahs.length; i++) {
      final ayah = AyahModel.fromCombinedData(
        arabicAyahs[i],
        i < translationAyahs.length ? translationAyahs[i] : null,
      );
      ayahs.add(ayah);
    }

    return SurahWithAyahs(surah: surah, ayahs: ayahs);
  }
}

class SearchResult {
  final SurahModel surah;
  final AyahModel ayah;
  final String highlightedText;

  SearchResult({
    required this.surah,
    required this.ayah,
    required this.highlightedText,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      surah: SurahModel.fromJson(json['surah']),
      ayah: AyahModel.fromJson(json),
      highlightedText: json['text'] ?? '',
    );
  }
}
