// import 'dart:convert';
// import 'package:islamia/data/models/quran/bookmark_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BookmarkService {
//   static const String _bookmarksKey = 'bookmarks';
  
//   // Get all bookmarks
//   Future<List<BookmarkModel>> getAllBookmarks() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      
//       return bookmarksJson
//           .map((json) => BookmarkModel.fromJson(jsonDecode(json)))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load bookmarks: $e');
//     }
//   }

//   // Add a new bookmark
//   Future<BookmarkModel> addBookmark(BookmarkModel bookmark) async {
//     try {
//       final bookmarks = await getAllBookmarks();
//       bookmarks.add(bookmark);
//       await _saveBookmarks(bookmarks);
//       return bookmark;
//     } catch (e) {
//       throw Exception('Failed to add bookmark: $e');
//     }
//   }

//   // Update a bookmark
//   Future<BookmarkModel> updateBookmark(BookmarkModel bookmark) async {
//     try {
//       final bookmarks = await getAllBookmarks();
//       final index = bookmarks.indexWhere((b) => b.id == bookmark.id);
      
//       if (index == -1) {
//         throw Exception('Bookmark not found');
//       }
      
//       bookmarks[index] = bookmark;
//       await _saveBookmarks(bookmarks);
//       return bookmark;
//     } catch (e) {
//       throw Exception('Failed to update bookmark: $e');
//     }
//   }

//   // Remove a bookmark
//   Future<void> removeBookmark(String bookmarkId) async {
//     try {
//       final bookmarks = await getAllBookmarks();
//       bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
//       await _saveBookmarks(bookmarks);
//     } catch (e) {
//       throw Exception('Failed to remove bookmark: $e');
//     }
//   }

//   // Clear all bookmarks
//   Future<void> clearAllBookmarks() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_bookmarksKey);
//     } catch (e) {
//       throw Exception('Failed to clear bookmarks: $e');
//     }
//   }

//   // Private helper method to save bookmarks
//   Future<void> _saveBookmarks(List<BookmarkModel> bookmarks) async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookmarksJson = bookmarks
//         .map((bookmark) => jsonEncode(bookmark.toJson()))
//         .toList();
    
//     await prefs.setStringList(_bookmarksKey, bookmarksJson);
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/quran/bookmark_service.dart';
import 'package:islamia/core/services/quran/quran_api_service.dart';
import 'package:islamia/core/services/quran/reading_history_service.dart';
import 'package:islamia/core/services/quran/settings_service.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
import 'package:islamia/data/models/quran/surah_model.dart';

// Service Providers
final quranApiServiceProvider = Provider<QuranApiService>((ref) {
  return QuranApiService();
});

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

final readingHistoryServiceProvider = Provider<ReadingHistoryService>((ref) {
  return ReadingHistoryService();
});

final quranSettingsServiceProvider = Provider<QuranSettingsService>((ref) {
  return QuranSettingsService();
});

// Initialization Provider
final quranServicesInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    debugPrint('Initializing Quran services...');
    
    // Initialize all services concurrently
    await Future.wait([
      ref.read(bookmarkServiceProvider).init(),
      ref.read(readingHistoryServiceProvider).init(),
      ref.read(quranSettingsServiceProvider).init(),
    ]);

    debugPrint('Quran services initialized successfully');
    return true;
  } catch (e) {
    debugPrint('Failed to initialize Quran services: $e');
    throw Exception('Failed to initialize Quran services: $e');
  }
});

// Surah Providers
final surahListProvider = FutureProvider<List<SurahModel>>((ref) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final apiService = ref.read(quranApiServiceProvider);
  try {
    final surahs = await apiService.getAllSurahs();
    debugPrint('Loaded ${surahs.length} surahs');
    return surahs;
  } catch (e) {
    debugPrint('Failed to load Surahs: $e');
    throw Exception('Failed to load Surahs: $e');
  }
});

final surahByNumberProvider = Provider.family<SurahModel?, int>((ref, surahNumber) {
  final surahListAsync = ref.watch(surahListProvider);
  
  return surahListAsync.when(
    data: (surahs) {
      try {
        return surahs.firstWhere((surah) => surah.number == surahNumber);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Ayah Providers
final surahAyahsProvider = FutureProvider.family<List<AyahModel>, SurahAyahsParams>((ref, params) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final apiService = ref.read(quranApiServiceProvider);
  try {
    debugPrint('Loading ayahs for Surah ${params.surahNumber} with translation ${params.translationEdition}');
    
    // Get Arabic text
    final arabicAyahs = await apiService.getSurahAyahs(
      params.surahNumber, 
      edition: params.arabicEdition
    );
    
    // Get translation if specified
    List<AyahModel> translationAyahs = [];
    if (params.translationEdition.isNotEmpty) {
      try {
        translationAyahs = await apiService.getSurahAyahs(
          params.surahNumber, 
          edition: params.translationEdition
        );
      } catch (e) {
        debugPrint('Failed to load translation, continuing with Arabic only: $e');
      }
    }
    
    // Combine Arabic and translation
    final combinedAyahs = <AyahModel>[];
    for (int i = 0; i < arabicAyahs.length; i++) {
      final arabicAyah = arabicAyahs[i];
      
      Map<String, String> translations = {};
      if (i < translationAyahs.length && params.translationEdition.isNotEmpty) {
        translations[params.translationEdition] = translationAyahs[i].text;
      }
      
      final combinedAyah = arabicAyah.copyWith(translations: translations);
      combinedAyahs.add(combinedAyah);
    }
    
    debugPrint('Successfully loaded ${combinedAyahs.length} ayahs for Surah ${params.surahNumber}');
    return combinedAyahs;
  } catch (e) {
    debugPrint('Failed to load Surah Ayahs: $e');
    throw Exception('Failed to load Surah Ayahs: $e');
  }
});

final ayahWithTranslationsProvider = FutureProvider.family<AyahModel, AyahParams>((ref, params) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final apiService = ref.read(quranApiServiceProvider);
  try {
    return await apiService.getAyahWithTranslations(
      params.surahNumber,
      params.ayahNumber,
      editions: params.editions,
    );
  } catch (e) {
    debugPrint('Failed to load Ayah with translations: $e');
    throw Exception('Failed to load Ayah with translations: $e');
  }
});

// Search Provider
final searchResultsProvider = FutureProvider.family<List<AyahModel>, SearchParams>((ref, params) async {
  if (params.query.isEmpty || params.query.length < 3) return [];
  
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final apiService = ref.read(quranApiServiceProvider);
  try {
    debugPrint('Searching for: ${params.query}');
    final results = await apiService.searchAyahs(
      params.query,
      edition: params.edition,
      limit: params.limit,
    );
    debugPrint('Found ${results.length} search results');
    return results;
  } catch (e) {
    debugPrint('Failed to search Ayahs: $e');
    throw Exception('Failed to search Ayahs: $e');
  }
});

// Juz Provider
final juzAyahsProvider = FutureProvider.family<List<AyahModel>, JuzParams>((ref, params) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final apiService = ref.read(quranApiServiceProvider);
  try {
    debugPrint('Loading Juz ${params.juzNumber}');
    final ayahs = await apiService.getJuzAyahs(
      params.juzNumber,
      edition: params.edition,
    );
    debugPrint('Loaded ${ayahs.length} ayahs for Juz ${params.juzNumber}');
    return ayahs;
  } catch (e) {
    debugPrint('Failed to load Juz Ayahs: $e');
    throw Exception('Failed to load Juz Ayahs: $e');
  }
});

// Bookmark Providers
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, AsyncValue<List<BookmarkModel>>>(
  (ref) => BookmarksNotifier(ref.read(bookmarkServiceProvider)),
);

final bookmarkCategoriesProvider = FutureProvider<List<String>>((ref) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final bookmarkService = ref.read(bookmarkServiceProvider);
  try {
    return await bookmarkService.getAllCategories();
  } catch (e) {
    debugPrint('Failed to load bookmark categories: $e');
    return ['General', 'Favorites', 'To Read', 'Important'];
  }
});

final bookmarkStatsProvider = FutureProvider<BookmarkStats>((ref) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final bookmarkService = ref.read(bookmarkServiceProvider);
  try {
    return await bookmarkService.getBookmarkStats();
  } catch (e) {
    debugPrint('Failed to load bookmark stats: $e');
    throw Exception('Failed to load bookmark stats: $e');
  }
});

final isBookmarkedProvider = FutureProvider.family<bool, AyahReference>((ref, ayahRef) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final bookmarkService = ref.read(bookmarkServiceProvider);
  try {
    return await bookmarkService.isBookmarked(ayahRef.surahNumber, ayahRef.ayahNumber);
  } catch (e) {
    debugPrint('Failed to check bookmark status: $e');
    return false;
  }
});

// StateNotifier for Bookmarks
class BookmarksNotifier extends StateNotifier<AsyncValue<List<BookmarkModel>>> {
  final BookmarkService _bookmarkService;
  
  BookmarksNotifier(this._bookmarkService) : super(const AsyncValue.loading()) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      state = const AsyncValue.loading();
      final bookmarks = await _bookmarkService.getAllBookmarks();
      state = AsyncValue.data(bookmarks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      await _bookmarkService.addBookmark(bookmark);
      await _loadBookmarks(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeBookmark(String bookmarkId) async {
    try {
      await _bookmarkService.removeBookmark(bookmarkId);
      await _loadBookmarks(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateBookmark(BookmarkModel bookmark) async {
    try {
      await _bookmarkService.updateBookmark(bookmark);
      await _loadBookmarks(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> toggleBookmark(BookmarkModel bookmark) async {
    try {
      final result = await _bookmarkService.toggleBookmark(bookmark);
      await _loadBookmarks(); // Refresh the list
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    try {
      return await _bookmarkService.isBookmarked(surahNumber, ayahNumber);
    } catch (e) {
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadBookmarks();
  }
}

// Parameter Classes
class SurahAyahsParams {
  final int surahNumber;
  final String arabicEdition;
  final String translationEdition;

  const SurahAyahsParams({
    required this.surahNumber,
    this.arabicEdition = 'ar.alafasy',
    this.translationEdition = 'en.sahih',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahAyahsParams &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          arabicEdition == other.arabicEdition &&
          translationEdition == other.translationEdition;

  @override
  int get hashCode => Object.hash(surahNumber, arabicEdition, translationEdition);
}

class AyahParams {
  final int surahNumber;
  final int ayahNumber;
  final List<String> editions;

  const AyahParams({
    required this.surahNumber,
    required this.ayahNumber,
    this.editions = const ['ar.alafasy', 'en.sahih'],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahParams &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber &&
          editions.toString() == other.editions.toString();

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, editions.hashCode);
}

class SearchParams {
  final String query;
  final String edition;
  final int limit;

  const SearchParams({
    required this.query,
    this.edition = 'en.sahih',
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          edition == other.edition &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(query, edition, limit);
}

class JuzParams {
  final int juzNumber;
  final String edition;

  const JuzParams({
    required this.juzNumber,
    this.edition = 'ar.alafasy',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JuzParams &&
          runtimeType == other.runtimeType &&
          juzNumber == other.juzNumber &&
          edition == other.edition;

  @override
  int get hashCode => Object.hash(juzNumber, edition);
}

class AyahReference {
  final int surahNumber;
  final int ayahNumber;

  const AyahReference({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahReference &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);
}

// Utility Providers
final quranStatsProvider = FutureProvider<QuranStats>((ref) async {
  try {
    final surahs = await ref.watch(surahListProvider.future);
    final bookmarkStats = await ref.watch(bookmarkStatsProvider.future);
    
    return QuranStats(
      totalSurahs: surahs.length,
      totalAyahs: surahs.fold(0, (sum, surah) => sum + surah.numberOfAyahs),
      bookmarkedAyahs: bookmarkStats.totalBookmarks,
      categoriesUsed: bookmarkStats.categoriesCount,
    );
  } catch (e) {
    throw Exception('Failed to calculate Quran stats: $e');
  }
});

class QuranStats {
  final int totalSurahs;
  final int totalAyahs;
  final int bookmarkedAyahs;
  final int categoriesUsed;

  const QuranStats({
    required this.totalSurahs,
    required this.totalAyahs,
    required this.bookmarkedAyahs,
    required this.categoriesUsed,
  });

  double get bookmarkPercentage => 
      totalAyahs > 0 ? (bookmarkedAyahs / totalAyahs) * 100 : 0.0;
}