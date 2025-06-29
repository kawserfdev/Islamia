import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/data/models/quran/reading_session.dart';
import 'package:islamia/core/services/quran/reading_history_service.dart';

final readingHistoryServiceProvider = Provider<ReadingHistoryService>((ref) {
  return ReadingHistoryService();
});

final readingHistoryProvider = StateNotifierProvider<ReadingHistoryNotifier, AsyncValue<List<ReadingSessionModel>>>((ref) {
  return ReadingHistoryNotifier(ref.read(readingHistoryServiceProvider));
});

final readingStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final historyService = ref.read(readingHistoryServiceProvider);
  return await historyService.getReadingStatistics();
});

final recentSessionsProvider = FutureProvider.family<List<ReadingSessionModel>, int>((ref, limit) async {
  final historyService = ref.read(readingHistoryServiceProvider);
  return await historyService.getRecentSessions(limit: limit);
});

class ReadingHistoryNotifier extends StateNotifier<AsyncValue<List<ReadingSessionModel>>> {
  final ReadingHistoryService _historyService;

  ReadingHistoryNotifier(this._historyService) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final sessions = await _historyService.getAllSessions();
      state = AsyncValue.data(sessions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSession({
    required int surahNumber,
    required int lastAyahRead,
    required Duration additionalTime,
  }) async {
    try {
      await _historyService.updateReadingSession(
        surahNumber: surahNumber,
        lastAyahRead: lastAyahRead,
        additionalTime: additionalTime,
      );
      await loadHistory();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<ReadingSessionModel?> getSession(int surahNumber) async {
    return await _historyService.getReadingSession(surahNumber);
  }

  Future<void> clearHistory() async {
    try {
      await _historyService.clearAllHistory();
      await loadHistory();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}