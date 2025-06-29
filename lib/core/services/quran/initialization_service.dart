import 'package:flutter/material.dart';
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