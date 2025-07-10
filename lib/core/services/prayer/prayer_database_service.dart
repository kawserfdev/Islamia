import 'dart:convert';
import 'package:islamia/data/models/prayer/prayer_log.dart';
import 'package:islamia/data/models/prayer/prayer_times_model.dart';
import 'package:islamia/data/models/prayer/prayer_tracking.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PrayerDatabaseService {
  static final PrayerDatabaseService _instance = PrayerDatabaseService._internal();
  factory PrayerDatabaseService() => _instance;
  PrayerDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'prayer_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE prayer_times (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        city TEXT NOT NULL,
        country TEXT NOT NULL,
        timezone TEXT NOT NULL,
        fajr TEXT NOT NULL,
        sunrise TEXT NOT NULL,
        dhuhr TEXT NOT NULL,
        asr TEXT NOT NULL,
        maghrib TEXT NOT NULL,
        isha TEXT NOT NULL,
        midnight TEXT,
        tahajjud TEXT,
        calculation_method TEXT NOT NULL,
        madhab TEXT NOT NULL,
        adjustments TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE prayer_tracking (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        prayer_type TEXT NOT NULL,
        prayed_at TEXT,
        is_qaza INTEGER DEFAULT 0,
        note TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE qaza_counter (
        id INTEGER PRIMARY KEY,
        prayer_type TEXT NOT NULL,
        count INTEGER DEFAULT 0,
        last_updated TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prayer_settings (
        id INTEGER PRIMARY KEY,
        settings_json TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_prayer_times_date ON prayer_times(date)');
    await db.execute('CREATE INDEX idx_prayer_tracking_date ON prayer_tracking(date)');
    await db.execute('CREATE INDEX idx_prayer_tracking_type ON prayer_tracking(prayer_type)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Prayer Times CRUD
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes) async {
    final db = await database;
    
    await db.insert(
      'prayer_times',
      {
        'id': prayerTimes.id,
        'date': prayerTimes.date.toIso8601String(),
        'latitude': prayerTimes.location.latitude,
        'longitude': prayerTimes.location.longitude,
        'city': prayerTimes.location.city,
        'country': prayerTimes.location.country,
        'timezone': prayerTimes.location.timezone,
        'fajr': prayerTimes.fajr.toIso8601String(),
        'sunrise': prayerTimes.sunrise.toIso8601String(),
        'dhuhr': prayerTimes.dhuhr.toIso8601String(),
        'asr': prayerTimes.asr.toIso8601String(),
        'maghrib': prayerTimes.maghrib.toIso8601String(),
        'isha': prayerTimes.isha.toIso8601String(),
        'midnight': prayerTimes.midnight?.toIso8601String(),
        'tahajjud': prayerTimes.tahajjud?.toIso8601String(),
        'calculation_method': prayerTimes.calculationMethod,
        'madhab': prayerTimes.madhab,
        'adjustments': jsonEncode(prayerTimes.adjustments),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PrayerTimesModel?> getCachedPrayerTimes(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'prayer_times',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      limit: 1,
    );

    if (result.isEmpty) return null;
    
    return _prayerTimesFromMap(result.first);
  }

  Future<Map<DateTime, PrayerTimesModel>> getCachedPrayerTimesForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    
    final result = await db.query(
      'prayer_times',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'date ASC',
    );

    final prayerTimesMap = <DateTime, PrayerTimesModel>{};
    for (final row in result) {
      final prayerTimes = _prayerTimesFromMap(row);
      prayerTimesMap[prayerTimes.date] = prayerTimes;
    }

    return prayerTimesMap;
  }

  // Prayer Tracking CRUD
  Future<void> trackPrayer(PrayerTracking tracking) async {
    final db = await database;
    
    await db.insert(
      'prayer_tracking',
      {
        'id': tracking.id,
        'date': tracking.date.toIso8601String(),
        'prayer_type': tracking.prayerType.name,
        'prayed_at': tracking.prayedAt?.toIso8601String(),
        'is_qaza': tracking.isQaza ? 1 : 0,
        'note': tracking.note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PrayerTracking>> getPrayerTrackingForDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'prayer_tracking',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      orderBy: 'prayer_type',
    );

    return result.map((row) => _prayerTrackingFromMap(row)).toList();
  }

  Future<Map<DateTime, List<PrayerTracking>>> getPrayerTrackingForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    
    final result = await db.query(
      'prayer_tracking',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'date, prayer_type',
    );

    final trackingMap = <DateTime, List<PrayerTracking>>{};
    for (final row in result) {
      final tracking = _prayerTrackingFromMap(row);
      final date = DateTime(tracking.date.year, tracking.date.month, tracking.date.day);
      
      if (!trackingMap.containsKey(date)) {
        trackingMap[date] = [];
      }
      trackingMap[date]!.add(tracking);
    }

    return trackingMap;
  }

  // Qaza Counter CRUD
  Future<void> updateQazaCounter(String prayerType, int count) async {
    final db = await database;
    
    await db.insert(
      'qaza_counter',
      {
        'prayer_type': prayerType,
        'count': count,
        'last_updated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<QazaCounter> getQazaCounter() async {
    final db = await database;
    
    final result = await db.query('qaza_counter');
    
    final missedPrayers = <String, int>{
      'fajr': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    };
    
    DateTime lastUpdated = DateTime.now();
    
    for (final row in result) {
      final prayerType = row['prayer_type'] as String;
      final count = row['count'] as int;
      final updated = DateTime.parse(row['last_updated'] as String);
      
      if (missedPrayers.containsKey(prayerType)) {
        missedPrayers[prayerType] = count;
      }
      
      if (updated.isAfter(lastUpdated)) {
        lastUpdated = updated;
      }
    }
    
    return QazaCounter(
      missedPrayers: missedPrayers,
      lastUpdated: lastUpdated,
    );
  }

  // Settings CRUD
  Future<void> savePrayerSettings(PrayerSettings settings) async {
    final db = await database;
    
    await db.insert(
      'prayer_settings',
      {
        'id': 1,
        'settings_json': jsonEncode(settings.toJson()),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PrayerSettings?> getPrayerSettings() async {
    final db = await database;
    
    final result = await db.query(
      'prayer_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) return null;
    
    final settingsJson = result.first['settings_json'] as String;
    final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
    
    return PrayerSettings.fromJson(settingsMap);
  }

  // Helper methods
  PrayerTimesModel _prayerTimesFromMap(Map<String, dynamic> map) {
    return PrayerTimesModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      location: LocationModel(
        latitude: map['latitude'],
        longitude: map['longitude'],
        city: map['city'],
        country: map['country'],
        timezone: map['timezone'],
      ),
      fajr: DateTime.parse(map['fajr']),
      sunrise: DateTime.parse(map['sunrise']),
      dhuhr: DateTime.parse(map['dhuhr']),
      asr: DateTime.parse(map['asr']),
      maghrib: DateTime.parse(map['maghrib']),
      isha: DateTime.parse(map['isha']),
      midnight: map['midnight'] != null ? DateTime.parse(map['midnight']) : null,
      tahajjud: map['tahajjud'] != null ? DateTime.parse(map['tahajjud']) : null,
      calculationMethod: map['calculation_method'],
      madhab: map['madhab'],
      adjustments: Map<String, int>.from(jsonDecode(map['adjustments'])), timezone: map['timezone'],
    );
  }

  PrayerTracking _prayerTrackingFromMap(Map<String, dynamic> map) {
    return PrayerTracking(
      id: map['id'],
      date: DateTime.parse(map['date']),
      prayerType: PrayerType.values.firstWhere((e) => e.name == map['prayer_type']),
      prayedAt: map['prayed_at'] != null ? DateTime.parse(map['prayed_at']) : null,
      isQaza: map['is_qaza'] == 1,
      note: map['note'],
    );
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('prayer_times');
    await db.delete('prayer_tracking');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}