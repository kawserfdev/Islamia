import 'dart:convert';
import 'package:islamia/data/models/quran/reading_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingHistoryService {
  static const String _historyKey = 'quran_reading_history';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'ReadingHistoryService not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  Future<void> updateReadingSession({
    required int surahNumber,
    required int lastAyahRead,
    required Duration additionalTime,
  }) async {
    final sessions = await getAllSessions();
    final sessionId = 'surah_$surahNumber';

    final existingIndex = sessions.indexWhere(
      (session) => session.id == sessionId,
    );

    if (existingIndex != -1) {
      // Update existing session
      final existingSession = sessions[existingIndex];
      final updatedSession = existingSession.copyWith(
        lastAyahRead: lastAyahRead,
        lastReadTime: DateTime.now(),
        totalReadingTime: existingSession.totalReadingTime + additionalTime,
      );
      sessions[existingIndex] = updatedSession;
    } else {
      // Create new session
      final newSession = ReadingSessionModel(
        id: sessionId,
        surahNumber: surahNumber,
        lastAyahRead: lastAyahRead,
        startTime: DateTime.now(),
        lastReadTime: DateTime.now(),
        totalReadingTime: additionalTime,
        progressPercentage: 0,
      );
      sessions.add(newSession);
    }

    await _saveSessions(sessions);
  }

  Future<ReadingSessionModel?> getReadingSession(int surahNumber) async {
    final sessions = await getAllSessions();
    final sessionId = 'surah_$surahNumber';

    try {
      return sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<List<ReadingSessionModel>> getAllSessions() async {
    try {
      final sessionsJson = prefs.getStringList(_historyKey) ?? [];
      final sessions =
          sessionsJson
              .map((json) => ReadingSessionModel.fromJson(jsonDecode(json)))
              .toList();

      // Sort by last read time (most recent first)
      sessions.sort((a, b) => b.lastReadTime.compareTo(a.lastReadTime));
      return sessions;
    } catch (e) {
      print('Error loading reading sessions: $e');
      return [];
    }
  }

  Future<List<ReadingSessionModel>> getRecentSessions({int limit = 10}) async {
    final sessions = await getAllSessions();
    return sessions.take(limit).toList();
  }

  Future<Duration> getTotalReadingTime() async {
    final sessions = await getAllSessions();
    Duration total = Duration.zero;
    for (final session in sessions) {
      total += session.totalReadingTime;
    }
    return total;
  }

  Future<void> _saveSessions(List<ReadingSessionModel> sessions) async {
    final sessionsJson =
        sessions.map((session) => jsonEncode(session.toJson())).toList();
    await prefs.setStringList(_historyKey, sessionsJson);
  }

  Future<void> clearAllHistory() async {
    await prefs.remove(_historyKey);
  }

  Future<int> getTotalSurahsRead() async {
    final sessions = await getAllSessions();
    return sessions.length;
  }

  Future<Map<String, dynamic>> getReadingStatistics() async {
    final sessions = await getAllSessions();
    final totalTime = await getTotalReadingTime();

    return {
      'totalSurahsRead': sessions.length,
      'totalReadingTime': totalTime,
      'averageSessionTime':
          sessions.isNotEmpty
              ? Duration(
                milliseconds: totalTime.inMilliseconds ~/ sessions.length,
              )
              : Duration.zero,
      'mostReadSurah': _getMostReadSurah(sessions),
      'readingStreak': _getReadingStreak(sessions),
    };
  }

  int? _getMostReadSurah(List<ReadingSessionModel> sessions) {
    if (sessions.isEmpty) return null;

    final surahCounts = <int, Duration>{};
    for (final session in sessions) {
      surahCounts[session.surahNumber] =
          (surahCounts[session.surahNumber] ?? Duration.zero) +
          session.totalReadingTime;
    }

    return surahCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _getReadingStreak(List<ReadingSessionModel> sessions) {
    if (sessions.isEmpty) return 0;

    final sortedSessions =
        sessions
            .map(
              (s) => DateTime(
                s.lastReadTime.year,
                s.lastReadTime.month,
                s.lastReadTime.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    for (final sessionDate in sortedSessions) {
      if (sessionDate == currentDate ||
          sessionDate == currentDate.subtract(Duration(days: streak))) {
        streak++;
        currentDate = sessionDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
