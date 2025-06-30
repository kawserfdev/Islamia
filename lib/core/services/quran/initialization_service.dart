import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/quran/quran_api_service.dart';
import 'bookmark_service.dart';
import 'reading_history_service.dart';
import 'settings_service.dart';

class QuranInitializationService {
  static final QuranInitializationService _instance = QuranInitializationService._internal();
  factory QuranInitializationService() => _instance;
  QuranInitializationService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize all services
      await Future.wait([
        BookmarkService().init(),
        ReadingHistoryService().init(),
        QuranSettingsService().init(),
      ]);

      _isInitialized = true;
      debugPrint('Quran services initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Quran services: $e');
      rethrow;
    }
  }

  bool get isInitialized => _isInitialized;
}
final quranApiServiceProvider = Provider<QuranApiService>((ref) => QuranApiService());
final bookmarkServiceProvider = Provider<BookmarkService>((ref) => BookmarkService());
final readingHistoryServiceProvider = Provider<ReadingHistoryService>((ref) => ReadingHistoryService());
final quranSettingsServiceProvider = Provider<QuranSettingsService>((ref) => QuranSettingsService());



final quranServicesInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    debugPrint('Initializing Quran services...');
    await Future.wait([
      ref.read(bookmarkServiceProvider).init(),
      ref.read(readingHistoryServiceProvider).init(),
      ref.read(quranSettingsServiceProvider).init(), // <-- Important!
    ]);
    return true;
  } catch (e) {
    debugPrint('Failed to initialize Quran services: $e');
    throw Exception('Failed to initialize Quran services: $e');
  }
});
