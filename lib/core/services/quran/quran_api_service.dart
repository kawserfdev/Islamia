import 'dart:convert';
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
  Future<List<SurahModel>> getAllSurahs({String language = 'en'}) async {
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

  // Get Surah Ayahs with specific edition
  Future<List<AyahModel>> getSurahAyahs(
    int surahNumber, {
    String edition = 'ar.alafasy',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$edition'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final surahData = data['data'];
        final List<dynamic> ayahsList = surahData['ayahs'];

        return ayahsList.map((ayahJson) {
          return AyahModel(
            number: ayahJson['number'],
            text: ayahJson['text'],
            surahNumber: surahData['number'],
            ayahNumber: ayahJson['numberInSurah'],
            juz: ayahJson['juz'] ?? 1,
            page: ayahJson['page'] ?? 1,
           // ruku: ayahJson['ruku'] ?? 1,
            //sajda: ayahJson['sajda'] ?? false,
            audioUrl: ayahJson['audio'],
          );
        }).toList();
      } else {
        throw QuranApiException('Failed to fetch surah ayahs: ${response.statusCode}');
      }
    } catch (e) {
      throw QuranApiException('Error fetching surah ayahs: $e');
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
        return AyahModel.fromApiResponse(data['data']);
      } else {
        throw QuranApiException('Failed to fetch ayah');
      }
    } catch (e) {
      throw QuranApiException('Error fetching ayah: $e');
    }
  }

  // Get Ayah with multiple translations/editions
  Future<AyahModel> getAyahWithTranslations(
    int surahNumber,
    int ayahNumber, {
    List<String> editions = const ['ar.alafasy', 'en.sahih'],
  }) async {
    try {
      final editionsParam = editions.join(',');
      final response = await _client.get(
        Uri.parse('$baseUrl/ayah/$surahNumber:$ayahNumber/editions/$editionsParam'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ayahsData = data['data'];

        if (ayahsData.isEmpty) {
          throw QuranApiException('No ayah data found');
        }

        // Get the primary ayah (usually Arabic)
        final primaryAyah = ayahsData.first;
        
        // Build translations map
        final translations = <String, String>{};
        for (int i = 1; i < ayahsData.length; i++) {
          final ayahData = ayahsData[i];
          final edition = ayahData['edition']['identifier'];
          translations[edition] = ayahData['text'];
        }

        return AyahModel(
          number: primaryAyah['number'],
          text: primaryAyah['text'],
          surahNumber: surahNumber,
          ayahNumber: primaryAyah['numberInSurah'],
          juz: primaryAyah['juz'] ?? 1,
          page: primaryAyah['page'] ?? 1,
          //ruku: primaryAyah['ruku'] ?? 1,
         // sajda: primaryAyah['sajda'] ?? false,
          translations: translations,
          audioUrl: primaryAyah['audio'],
        );
      } else {
        throw QuranApiException('Failed to fetch ayah with translations: ${response.statusCode}');
      }
    } catch (e) {
      throw QuranApiException('Error fetching ayah with translations: $e');
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

  // Search Ayahs (alias for searchQuran but returns AyahModel list)
  Future<List<AyahModel>> searchAyahs(
    String query, {
    String edition = 'en.sahih',
    int limit = 20,
  }) async {
    try {
      final searchResults = await searchQuran(query, translation: edition, limit: limit);
      return searchResults.map((result) => result.ayah).toList();
    } catch (e) {
      throw QuranApiException('Error searching ayahs: $e');
    }
  }

  // Get Juz Ayahs
  Future<List<AyahModel>> getJuzAyahs(
    int juzNumber, {
    String edition = 'ar.alafasy',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/juz/$juzNumber/$edition'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final juzData = data['data'];
        final List<dynamic> ayahsList = juzData['ayahs'];

        return ayahsList.map((ayahJson) {
          return AyahModel(
            number: ayahJson['number'],
            text: ayahJson['text'],
            surahNumber: ayahJson['surah']['number'],
            ayahNumber: ayahJson['numberInSurah'],
            juz: ayahJson['juz'] ?? juzNumber,
            page: ayahJson['page'] ?? 1,
           // ruku: ayahJson['ruku'] ?? 1,
           // sajda: ayahJson['sajda'] ?? false,
            audioUrl: ayahJson['audio'],
          );
        }).toList();
      } else {
        throw QuranApiException('Failed to fetch juz ayahs: ${response.statusCode}');
      }
    } catch (e) {
      throw QuranApiException('Error fetching juz ayahs: $e');
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

  // Get available translations
  Future<List<Translation>> getTranslations() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/edition/type/translation'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> translations = data['data'];

        return translations.map((json) => Translation.fromJson(json)).toList();
      } else {
        throw QuranApiException('Failed to fetch translations');
      }
    } catch (e) {
      throw QuranApiException('Error fetching translations: $e');
    }
  }

  // Get Quran metadata
  Future<QuranMetadata> getQuranMetadata() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/meta'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuranMetadata.fromJson(data['data']);
      } else {
        throw QuranApiException('Failed to fetch Quran metadata');
      }
    } catch (e) {
      throw QuranApiException('Error fetching Quran metadata: $e');
    }
  }

  // Note: These methods are typically handled by local services, not API
  // But I'm including them as requested with default implementations

  // Get all bookmark categories (local implementation)
  Future<List<String>> getAllCategories() async {
    // This would typically be handled by BookmarkService
    // Returning default categories as this is usually a local operation
    return [
      'General',
      'Favorites',
      'To Read',
      'Important',
      'Memorization',
      'Reflection',
      'Daily Reading',
      'Study Notes',
    ];
  }

  // Get bookmark statistics (local implementation)
  Future<BookmarkStats> getBookmarkStats() async {
    // This would typically be handled by BookmarkService
    // Returning a default empty stats object
    return BookmarkStats(
      totalBookmarks: 0,
      categoriesCount: 0,
      surahsWithBookmarks: 0,
      categoryDistribution: {},
    );
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

class Translation {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;

  Translation({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      identifier: json['identifier'],
      language: json['language'],
      name: json['name'],
      englishName: json['englishName'],
      format: json['format'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'language': language,
      'name': name,
      'englishName': englishName,
      'format': format,
      'type': type,
    };
  }
}

class QuranMetadata {
  final int ayahsCount;
  final int surahs;
  final int rukus;
  final int pages;
  final int manzils;
  final int sajdas;

  QuranMetadata({
    required this.ayahsCount,
    required this.surahs,
    required this.rukus,
    required this.pages,
    required this.manzils,
    required this.sajdas,
  });

  factory QuranMetadata.fromJson(Map<String, dynamic> json) {
    return QuranMetadata(
      ayahsCount: json['ayahs']['count'],
      surahs: json['surahs']['count'],
      rukus: json['rukus']['count'],
      pages: json['pages']['count'],
      manzils: json['manzils']['count'],
      sajdas: json['sajdas']['count'],
    );
  }
}

class BookmarkStats {
  final int totalBookmarks;
  final int categoriesCount;
  final int surahsWithBookmarks;
  final Map<String, int> categoryDistribution;

  BookmarkStats({
    required this.totalBookmarks,
    required this.categoriesCount,
    required this.surahsWithBookmarks,
    required this.categoryDistribution,
  });

  factory BookmarkStats.fromJson(Map<String, dynamic> json) {
    return BookmarkStats(
      totalBookmarks: json['totalBookmarks'] ?? 0,
      categoriesCount: json['categoriesCount'] ?? 0,
      surahsWithBookmarks: json['surahsWithBookmarks'] ?? 0,
      categoryDistribution: Map<String, int>.from(json['categoryDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBookmarks': totalBookmarks,
      'categoriesCount': categoriesCount,
      'surahsWithBookmarks': surahsWithBookmarks,
      'categoryDistribution': categoryDistribution,
    };
  }
}