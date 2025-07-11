import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'islamia_app.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades for app data
    if (oldVersion < newVersion) {
      await _createTables(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Quran data tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS surahs (
        id INTEGER PRIMARY KEY,
        number INTEGER NOT NULL,
        name TEXT NOT NULL,
        english_name TEXT NOT NULL,
        english_translation TEXT NOT NULL,
        number_of_ayahs INTEGER NOT NULL,
        revelation_type TEXT NOT NULL,
        revelation_order INTEGER,
        juz_number INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ayahs (
        id INTEGER PRIMARY KEY,
        number INTEGER NOT NULL,
        text TEXT NOT NULL,
         surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        juz INTEGER NOT NULL,
        manzil INTEGER NOT NULL,
        page INTEGER NOT NULL,
        ruku INTEGER NOT NULL,
        hizb_quarter INTEGER NOT NULL,
        sajda INTEGER DEFAULT 0,
        FOREIGN KEY (surah_number) REFERENCES surahs (number)
      )
    ''');

    // Quran translations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ayah_translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ayah_id INTEGER NOT NULL,
        language TEXT NOT NULL,
        translation TEXT NOT NULL,
        translator TEXT,
        FOREIGN KEY (ayah_id) REFERENCES ayahs (id) ON DELETE CASCADE
      )
    ''');

    // Hadith data tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadith_collections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        arabic_name TEXT NOT NULL,
        author TEXT NOT NULL,
        description TEXT,
        total_hadith INTEGER NOT NULL,
        total_books INTEGER NOT NULL,
        language TEXT DEFAULT 'en'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadith_books (
        id TEXT PRIMARY KEY,
        collection_id TEXT NOT NULL,
        number TEXT NOT NULL,
        name TEXT NOT NULL,
        arabic_name TEXT NOT NULL,
        total_hadith INTEGER NOT NULL,
        FOREIGN KEY (collection_id) REFERENCES hadith_collections (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadiths (
        id TEXT PRIMARY KEY,
        collection_id TEXT NOT NULL,
        book_id TEXT NOT NULL,
        hadith_number TEXT NOT NULL,
        chapter TEXT,
        section_name TEXT,
        arabic_text TEXT NOT NULL,
        narrator TEXT,
        grade TEXT,
        FOREIGN KEY (collection_id) REFERENCES hadith_collections (id) ON DELETE CASCADE,
        FOREIGN KEY (book_id) REFERENCES hadith_books (id) ON DELETE CASCADE
      )
    ''');

    // Prayer times cache table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prayer_times_cache (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        fajr TEXT NOT NULL,
        sunrise TEXT NOT NULL,
        dhuhr TEXT NOT NULL,
        asr TEXT NOT NULL,
        maghrib TEXT NOT NULL,
        isha TEXT NOT NULL,
        calculation_method TEXT NOT NULL,
        madhab TEXT NOT NULL,
        timezone TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL, -- 'quran' or 'hadith'
        reference_id TEXT NOT NULL, -- ayah_id or hadith_id
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        note TEXT,
        tags TEXT, -- JSON array of tags
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Islamic calendar events table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS islamic_events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        arabic_name TEXT NOT NULL,
        description TEXT,
        event_type TEXT NOT NULL,
        importance TEXT NOT NULL,
        hijri_month INTEGER NOT NULL,
        hijri_day INTEGER NOT NULL,
        is_recurring INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Dua categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dua_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        arabic_name TEXT,
        description TEXT,
        icon TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // Duas table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS duas (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        title TEXT NOT NULL,
        arabic_title TEXT,
        arabic_text TEXT NOT NULL,
        transliteration TEXT NOT NULL,
        reference TEXT,
        occasion TEXT,
        benefits TEXT,
        audio_url TEXT,
        FOREIGN KEY (category_id) REFERENCES dua_categories (id) ON DELETE CASCADE
      )
    ''');

    // Dua translations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dua_translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dua_id TEXT NOT NULL,
        language TEXT NOT NULL,
        translation TEXT NOT NULL,
        FOREIGN KEY (dua_id) REFERENCES duas (id) ON DELETE CASCADE
      )
    ''');

    // Audio cache table for downloaded recitations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS audio_cache (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL, -- 'quran', 'dua', 'adhan'
        reference_id TEXT NOT NULL,
        reciter_id TEXT,
        file_path TEXT NOT NULL,
        file_size INTEGER,
        duration INTEGER,
        downloaded_at TEXT NOT NULL,
        last_accessed TEXT NOT NULL
      )
    ''');

    print('Database tables created successfully');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear all app data tables
      await txn.delete('surahs');
      await txn.delete('ayahs');
      await txn.delete('ayah_translations');
      await txn.delete('hadith_collections');
      await txn.delete('hadith_books');
      await txn.delete('hadiths');
      await txn.delete('prayer_times_cache');
      await txn.delete('bookmarks');
      await txn.delete('islamic_events');
      await txn.delete('dua_categories');
      await txn.delete('duas');
      await txn.delete('dua_translations');
      await txn.delete('audio_cache');
    });
  }
}