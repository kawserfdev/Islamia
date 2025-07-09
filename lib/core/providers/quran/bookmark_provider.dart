import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/bookmark_notifier.dart';
import 'package:islamia/core/services/quran/parameter_classes.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
import 'package:islamia/core/services/quran/bookmark_service.dart';
import 'package:islamia/core/services/quran/quran_api_service.dart';
import 'package:islamia/core/services/quran/reading_history_service.dart';
import 'package:islamia/core/services/quran/settings_service.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import 'package:islamia/data/models/quran/surah_model.dart';


// final bookmarksProvider = StateNotifierProvider<BookmarkNotifier, AsyncValue<List<BookmarkModel>>>((ref) {
//   return BookmarkNotifier(ref.read(bookmarkServiceProvider));
// });

final bookmarksProvider = StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  return BookmarkNotifier(ref.read(bookmarkServiceProvider));
});


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

//Bookmark Providers
// final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, AsyncValue<List<BookmarkModel>>>(
//   (ref) => BookmarksNotifier(ref.read(bookmarkServiceProvider)),
// );

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

final bookmarkStatsProvider = FutureProvider<BookmarkServiceStats>((ref) async {
  // Ensure services are initialized
  await ref.watch(quranServicesInitializationProvider.future);
  
  final bookmarkService = ref.read(bookmarkServiceProvider);
  try {
    return  bookmarkService.getBookmarkStats();
  } catch (e) {
    debugPrint('Failed to load bookmark stats: $e');
    throw Exception('Failed to load bookmark stats: $e');
  }
});

// final isBookmarkedProvider = FutureProvider.family<bool, AyahReference>((ref, ayahRef) async {
//   // Ensure services are initialized
//   await ref.watch(quranServicesInitializationProvider.future);
  
//   final bookmarkService = ref.read(bookmarkServiceProvider);
//   try {
//     return await bookmarkService.isBookmarked(ayahRef.surahNumber, ayahRef.ayahNumber);
//   } catch (e) {
//     debugPrint('Failed to check bookmark status: $e');
//     return false;
//   }
// });

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
