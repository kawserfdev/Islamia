class UserStatistics {
  final PrayerStatistics prayerStats;
  final ReadingStatistics readingStats;
  final List<Achievement> recentAchievements;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivity;
  final Map<String, int> monthlyStats;

  const UserStatistics({
    required this.prayerStats,
    required this.readingStats,
    this.recentAchievements = const [],
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivity,
    this.monthlyStats = const {},
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      prayerStats: PrayerStatistics.fromJson(json['prayer_stats'] ?? {}),
      readingStats: ReadingStatistics.fromJson(json['reading_stats'] ?? {}),
      recentAchievements: (json['recent_achievements'] as List?)
          ?.map((e) => Achievement.fromJson(e))
          .toList() ?? [],
      totalPoints: json['total_points'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActivity: json['last_activity'] != null 
          ? DateTime.parse(json['last_activity']) 
          : null,
      monthlyStats: Map<String, int>.from(json['monthly_stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prayer_stats': prayerStats.toJson(),
      'reading_stats': readingStats.toJson(),
      'recent_achievements': recentAchievements.map((e) => e.toJson()).toList(),
      'total_points': totalPoints,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity': lastActivity?.toIso8601String(),
      'monthly_stats': monthlyStats,
    };
  }

  UserStatistics copyWith({
    PrayerStatistics? prayerStats,
    ReadingStatistics? readingStats,
    List<Achievement>? recentAchievements,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivity,
    Map<String, int>? monthlyStats,
  }) {
    return UserStatistics(
      prayerStats: prayerStats ?? this.prayerStats,
      readingStats: readingStats ?? this.readingStats,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivity: lastActivity ?? this.lastActivity,
      monthlyStats: monthlyStats ?? this.monthlyStats,
    );
  }
}

class PrayerStatistics {
  final int totalPrayers;
  final int prayersOnTime;
  final int currentPrayerStreak;
  final int longestPrayerStreak;
  final Map<String, int> prayerCounts; // fajr, dhuhr, asr, maghrib, isha
  final double averageAttendance;
  final DateTime? lastPrayerTime;

  const PrayerStatistics({
    this.totalPrayers = 0,
    this.prayersOnTime = 0,
    this.currentPrayerStreak = 0,
    this.longestPrayerStreak = 0,
    this.prayerCounts = const {},
    this.averageAttendance = 0.0,
    this.lastPrayerTime,
  });

  factory PrayerStatistics.fromJson(Map<String, dynamic> json) {
    return PrayerStatistics(
      totalPrayers: json['total_prayers'] ?? 0,
      prayersOnTime: json['prayers_on_time'] ?? 0,
      currentPrayerStreak: json['current_prayer_streak'] ?? 0,
      longestPrayerStreak: json['longest_prayer_streak'] ?? 0,
      prayerCounts: Map<String, int>.from(json['prayer_counts'] ?? {}),
      averageAttendance: (json['average_attendance'] ?? 0.0).toDouble(),
      lastPrayerTime: json['last_prayer_time'] != null 
          ? DateTime.parse(json['last_prayer_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_prayers': totalPrayers,
      'prayers_on_time': prayersOnTime,
      'current_prayer_streak': currentPrayerStreak,
      'longest_prayer_streak': longestPrayerStreak,
      'prayer_counts': prayerCounts,
      'average_attendance': averageAttendance,
      'last_prayer_time': lastPrayerTime?.toIso8601String(),
    };
  }

  double get onTimePercentage {
    if (totalPrayers == 0) return 0.0;
    return (prayersOnTime / totalPrayers) * 100;
  }
}

class ReadingStatistics {
  final int totalQuranAyahs;
  final int completedSurahs;
  final int totalHadithsRead;
  final int readingSessionsCount;
  final Duration totalReadingTime;
  final int currentReadingStreak;
  final int longestReadingStreak;
  final DateTime? lastReadingSession;
  final Map<String, int> monthlyProgress;

  const ReadingStatistics({
    this.totalQuranAyahs = 0,
    this.completedSurahs = 0,
    this.totalHadithsRead = 0,
    this.readingSessionsCount = 0,
    this.totalReadingTime = Duration.zero,
    this.currentReadingStreak = 0,
    this.longestReadingStreak = 0,
    this.lastReadingSession,
    this.monthlyProgress = const {},
  });

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) {
    return ReadingStatistics(
      totalQuranAyahs: json['total_quran_ayahs'] ?? 0,
      completedSurahs: json['completed_surahs'] ?? 0,
      totalHadithsRead: json['total_hadiths_read'] ?? 0,
      readingSessionsCount: json['reading_sessions_count'] ?? 0,
      totalReadingTime: Duration(milliseconds: json['total_reading_time_ms'] ?? 0),
      currentReadingStreak: json['current_reading_streak'] ?? 0,
      longestReadingStreak: json['longest_reading_streak'] ?? 0,
      lastReadingSession: json['last_reading_session'] != null 
          ? DateTime.parse(json['last_reading_session'])
          : null,
      monthlyProgress: Map<String, int>.from(json['monthly_progress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_quran_ayahs': totalQuranAyahs,
      'completed_surahs': completedSurahs,
      'total_hadiths_read': totalHadithsRead,
      'reading_sessions_count': readingSessionsCount,
      'total_reading_time_ms': totalReadingTime.inMilliseconds,
      'current_reading_streak': currentReadingStreak,
      'longest_reading_streak': longestReadingStreak,
      'last_reading_session': lastReadingSession?.toIso8601String(),
      'monthly_progress': monthlyProgress,
    };
  }

  double get quranCompletionPercentage {
    const totalAyahs = 6236; // Total ayahs in Quran
    return (totalQuranAyahs / totalAyahs) * 100;
  }

  double get surahCompletionPercentage {
    const totalSurahs = 114; // Total surahs in Quran
    return (completedSurahs / totalSurahs) * 100;
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final AchievementCategory category;
  final int points;
  final DateTime unlockedAt;
  final Map<String, dynamic> criteria;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.points,
    required this.unlockedAt,
    this.criteria = const {},
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['icon_url'],
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.general,
      ),
      points: json['points'] ?? 0,
      unlockedAt: DateTime.parse(json['unlocked_at']),
      criteria: Map<String, dynamic>.from(json['criteria'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_url': iconUrl,
      'category': category.name,
      'points': points,
      'unlocked_at': unlockedAt.toIso8601String(),
      'criteria': criteria,
    };
  }
}

enum AchievementCategory {
  general,
  prayer,
  reading,
  learning,
  community,
  ramadan,
  hajj,
}
