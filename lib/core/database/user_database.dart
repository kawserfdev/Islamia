import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import '../models/user/user_profile.dart';

class UserDatabase {
  static final UserDatabase _instance = UserDatabase._internal();
  factory UserDatabase() => _instance;
  UserDatabase._internal();

  static Database? _database;
  static const String _encryptionKey = 'your-encryption-key-here';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'islamia_user.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // User profiles table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        email TEXT,
        phone_number TEXT,
        display_name TEXT,
        first_name TEXT,
        last_name TEXT,
        photo_url TEXT,
        bio TEXT,
        date_of_birth INTEGER,
        gender TEXT,
        location TEXT,
        madhab TEXT DEFAULT 'Shafi',
        calculation_method TEXT DEFAULT 'ISNA',
        statistics TEXT,
        preferences TEXT,
        privacy_settings TEXT,
        achievements TEXT,
        account_type TEXT DEFAULT 'individual',
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        last_login_at INTEGER,
        is_verified INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        metadata TEXT,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // User sessions table
    await db.execute('''
      CREATE TABLE user_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        device_id TEXT NOT NULL,
        device_name TEXT,
        platform TEXT,
        app_version TEXT,
        created_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        last_activity INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // User statistics tracking
    await db.execute('''
      CREATE TABLE user_activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        activity_type TEXT NOT NULL,
        activity_data TEXT,
        timestamp INTEGER NOT NULL,
        session_id TEXT,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // Prayer tracking
    await db.execute('''
      CREATE TABLE prayer_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        prayer_name TEXT NOT NULL,
        prayer_time INTEGER NOT NULL,
        actual_time INTEGER NOT NULL,
        is_on_time INTEGER DEFAULT 0,
        location TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // Reading progress tracking
    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content_type TEXT NOT NULL, -- 'quran', 'hadith'
        content_id TEXT NOT NULL,
        progress_percentage REAL DEFAULT 0.0,
        time_spent INTEGER DEFAULT 0,
        last_position TEXT,
        completed_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // User achievements
    await db.execute('''
      CREATE TABLE user_achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        achievement_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        points INTEGER DEFAULT 0,
        unlocked_at INTEGER NOT NULL,
        criteria TEXT,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // Backup history
    await db.execute('''
      CREATE TABLE backup_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        backup_type TEXT NOT NULL,
        backup_size INTEGER,
        backup_location TEXT,
        created_at INTEGER NOT NULL,
        restored_at INTEGER,
        status TEXT DEFAULT 'completed',
        error_message TEXT,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_user_profiles_email ON user_profiles (email)',
    );
    await db.execute(
      'CREATE INDEX idx_user_sessions_user_id ON user_sessions (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_prayer_logs_user_date ON prayer_logs (user_id, prayer_time)',
    );
    await db.execute(
      'CREATE INDEX idx_reading_progress_user ON reading_progress (user_id, content_type)',
    );
    await db.execute(
      'CREATE INDEX idx_user_achievements_user ON user_achievements (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_activity_log_user_time ON user_activity_log (user_id, timestamp)',
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades
  }

  // User profile operations
  Future<void> insertUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profiles',
      _encryptSensitiveData(profile.toJson()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final db = await database;
    final results = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      final decryptedData = _decryptSensitiveData(results.first);
      return UserProfile.fromJson(decryptedData);
    }
    return null;
  }

  Future<UserProfile?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'user_profiles',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      final decryptedData = _decryptSensitiveData(results.first);
      return UserProfile.fromJson(decryptedData);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      'user_profiles',
      _encryptSensitiveData(profile.toJson()),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<void> updateLastLogin(String userId) async {
    final db = await database;
    await db.update(
      'user_profiles',
      {'last_login_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Prayer logging
  Future<void> logPrayer({
    required String userId,
    required String prayerName,
    required DateTime prayerTime,
    required DateTime actualTime,
    String? location,
    String? notes,
  }) async {
    final db = await database;
    final isOnTime = actualTime.difference(prayerTime).inMinutes.abs() <= 15;

    await db.insert('prayer_logs', {
      'user_id': userId,
      'prayer_name': prayerName,
      'prayer_time': prayerTime.millisecondsSinceEpoch,
      'actual_time': actualTime.millisecondsSinceEpoch,
      'is_on_time': isOnTime ? 1 : 0,
      'location': location,
      'notes': notes,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Update user statistics
    await _updatePrayerStatistics(userId);
  }

  Future<PrayerStatistics> getPrayerStatistics(String userId) async {
    final db = await database;

    // Get total prayers
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM prayer_logs WHERE user_id = ?',
      [userId],
    );
    final total = totalResult.first['total'] as int;

    // Get on-time prayers
    final onTimeResult = await db.rawQuery(
      'SELECT COUNT(*) as on_time FROM prayer_logs WHERE user_id = ? AND is_on_time = 1',
      [userId],
    );
    final onTime = onTimeResult.first['on_time'] as int;

    // Get prayer counts by type
    final countsResult = await db.rawQuery(
      'SELECT prayer_name, COUNT(*) as count FROM prayer_logs WHERE user_id = ? GROUP BY prayer_name',
      [userId],
    );
    final prayerCounts = <String, int>{};
    for (final row in countsResult) {
      prayerCounts[row['prayer_name'] as String] = row['count'] as int;
    }

    // Calculate current streak
    final currentStreak = await _calculatePrayerStreak(userId);

    return PrayerStatistics(
      totalPrayers: total,
      prayersOnTime: onTime,
      currentPrayerStreak: currentStreak,
      prayerCounts: prayerCounts,
      averageAttendance: total > 0 ? (onTime / total) * 100 : 0.0,
    );
  }

  // Reading progress tracking
  Future<void> updateReadingProgress({
    required String userId,
    required String contentType,
    required String contentId,
    required double progressPercentage,
    int timeSpent = 0,
    String? lastPosition,
  }) async {
    final db = await database;

    await db.insert('reading_progress', {
      'user_id': userId,
      'content_type': contentType,
      'content_id': contentId,
      'progress_percentage': progressPercentage,
      'time_spent': timeSpent,
      'last_position': lastPosition,
      'completed_at':
          progressPercentage >= 100.0
              ? DateTime.now().millisecondsSinceEpoch
              : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await _updateReadingStatistics(userId);
  }

  Future<ReadingStatistics> getReadingStatistics(String userId) async {
    final db = await database;

    // Get Quran progress
    final quranResult = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_readings,
        SUM(CASE WHEN completed_at IS NOT NULL THEN 1 ELSE 0 END) as completed_count,
        SUM(time_spent) as total_time
      FROM reading_progress 
      WHERE user_id = ? AND content_type = 'quran'
    ''',
      [userId],
    );

    // Get Hadith progress
    final hadithResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as hadith_count
      FROM reading_progress 
      WHERE user_id = ? AND content_type = 'hadith' AND completed_at IS NOT NULL
    ''',
      [userId],
    );

    final quranData = quranResult.first;
    final hadithData = hadithResult.first;

    return ReadingStatistics(
      totalQuranAyahs: quranData['total_readings'] as int? ?? 0,
      completedSurahs: quranData['completed_count'] as int? ?? 0,
      totalHadithsRead: hadithData['hadith_count'] as int? ?? 0,
      totalReadingTime: Duration(
        milliseconds: quranData['total_time'] as int? ?? 0,
      ),
    );
  }

  // Achievement system
  Future<void> unlockAchievement({
    required String userId,
    required String achievementId,
    required String title,
    required String description,
    required AchievementCategory category,
    int points = 0,
    Map<String, dynamic> criteria = const {},
  }) async {
    final db = await database;

    // Check if already unlocked
    final existing = await db.query(
      'user_achievements',
      where: 'user_id = ? AND achievement_id = ?',
      whereArgs: [userId, achievementId],
    );

    if (existing.isEmpty) {
      await db.insert('user_achievements', {
        'user_id': userId,
        'achievement_id': achievementId,
        'title': title,
        'description': description,
        'category': category.name,
        'points': points,
        'unlocked_at': DateTime.now().millisecondsSinceEpoch,
        'criteria': jsonEncode(criteria),
      });

      // Update user's total points
      await _updateUserPoints(userId, points);
    }
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    final db = await database;
    final results = await db.query(
      'user_achievements',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'unlocked_at DESC',
    );

    return results
        .map(
          (row) => Achievement(
            id: row['achievement_id'] as String,
            title: row['title'] as String,
            description: row['description'] as String,
            iconUrl: '', // You can add icon logic here
            category: AchievementCategory.values.firstWhere(
              (e) => e.name == row['category'],
              orElse: () => AchievementCategory.general,
            ),
            points: row['points'] as int,
            unlockedAt: DateTime.fromMillisecondsSinceEpoch(
              row['unlocked_at'] as int,
            ),
            criteria: jsonDecode(row['criteria'] as String? ?? '{}'),
          ),
        )
        .toList();
  }

  // Activity logging
  Future<void> logActivity({
    required String userId,
    required String activityType,
    Map<String, dynamic>? activityData,
    String? sessionId,
  }) async {
    final db = await database;
    await db.insert('user_activity_log', {
      'user_id': userId,
      'activity_type': activityType,
      'activity_data': activityData != null ? jsonEncode(activityData) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'session_id': sessionId,
    });
  }

  // Session management
  Future<void> createUserSession({
    required String userId,
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
  }) async {
    final db = await database;
    final sessionId = _generateSessionId();
    final expiresAt = DateTime.now().add(const Duration(days: 30));

    await db.insert('user_sessions', {
      'id': sessionId,
      'user_id': userId,
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform,
      'app_version': appVersion,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'expires_at': expiresAt.millisecondsSinceEpoch,
      'last_activity': DateTime.now().millisecondsSinceEpoch,
      'is_active': 1,
    });
  }

  Future<void> updateSessionActivity(String sessionId) async {
    final db = await database;
    await db.update(
      'user_sessions',
      {'last_activity': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deactivateSession(String sessionId) async {
    final db = await database;
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Data backup
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    final db = await database;

    // Get user profile
    final profile = await getUserProfile(userId);

    // Get prayer logs
    final prayerLogs = await db.query(
      'prayer_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Get reading progress
    final readingProgress = await db.query(
      'reading_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Get achievements
    final achievements = await db.query(
      'user_achievements',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return {
      'profile': profile?.toJson(),
      'prayer_logs': prayerLogs,
      'reading_progress': readingProgress,
      'achievements': achievements,
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  // Data cleanup for account deletion
  Future<void> deleteUserData(String userId) async {
    final db = await database;

    // Delete in correct order to respect foreign key constraints
    await db.delete(
      'user_activity_log',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.delete('prayer_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete(
      'reading_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.delete(
      'user_achievements',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.delete(
      'backup_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.delete('user_sessions', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('user_profiles', where: 'id = ?', whereArgs: [userId]);
  }

  // Helper methods
  Map<String, dynamic> _encryptSensitiveData(Map<String, dynamic> data) {
    // Encrypt sensitive fields
    final sensitiveFields = ['email', 'phone_number', 'bio', 'location'];
    final encryptedData = Map<String, dynamic>.from(data);

    for (final field in sensitiveFields) {
      if (encryptedData[field] != null) {
        encryptedData[field] = _encrypt(encryptedData[field].toString());
      }
    }

    return encryptedData;
  }

  Map<String, dynamic> _decryptSensitiveData(Map<String, dynamic> data) {
    // Decrypt sensitive fields
    final sensitiveFields = ['email', 'phone_number', 'bio', 'location'];
    final decryptedData = Map<String, dynamic>.from(data);

    for (final field in sensitiveFields) {
      if (decryptedData[field] != null) {
        try {
          decryptedData[field] = _decrypt(decryptedData[field].toString());
        } catch (e) {
          // If decryption fails, keep original value
        }
      }
    }

    return decryptedData;
  }

  String _encrypt(String text) {
    // Simple encryption - in production, use proper encryption
    final bytes = utf8.encode(text + _encryptionKey);
    return base64.encode(bytes);
  }

  String _decrypt(String encryptedText) {
    // Simple decryption - in production, use proper decryption
    final bytes = base64.decode(encryptedText);
    final decrypted = utf8.decode(bytes);
    return decrypted.replaceAll(_encryptionKey, '');
  }

  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = (timestamp.hashCode).toString();
    return base64.encode(utf8.encode('$timestamp$random')).substring(0, 32);
  }

  Future<void> _updatePrayerStatistics(String userId) async {
    // This would update the user's prayer statistics in the profile
    // Implementation depends on your statistics calculation logic
  }

  Future<void> _updateReadingStatistics(String userId) async {
    // This would update the user's reading statistics in the profile
    // Implementation depends on your statistics calculation logic
  }

  Future<int> _calculatePrayerStreak(String userId) async {
    // Calculate current prayer streak
    // This is a simplified version - you'd implement proper streak calculation
    return 0;
  }

  Future<void> _updateUserPoints(String userId, int additionalPoints) async {
    // Update user's total points
    final profile = await getUserProfile(userId);
    if (profile != null) {
      final updatedStats = profile.statistics.copyWith(
        totalPoints: profile.statistics.totalPoints + additionalPoints,
      );
      final updatedProfile = profile.copyWith(statistics: updatedStats);
      await updateUserProfile(updatedProfile);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
