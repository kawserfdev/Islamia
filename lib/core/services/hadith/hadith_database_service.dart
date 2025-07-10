import 'dart:convert';
import 'package:islamia/data/models/hadith/hadith_collection.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../data/models/hadith/hadith_bookmark.dart';

class HadithDatabaseService {
  static final HadithDatabaseService _instance = HadithDatabaseService._internal();
  factory HadithDatabaseService() => _instance;
  HadithDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'hadith_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hadiths (
        id TEXT PRIMARY KEY,
        collection TEXT NOT NULL,
        book TEXT NOT NULL,
        book_number TEXT NOT NULL,
        hadith_number TEXT NOT NULL,
        chapter TEXT NOT NULL,
        section TEXT NOT NULL,
        arabic_text TEXT NOT NULL,
        translations TEXT NOT NULL,
        narrator TEXT NOT NULL,
        narrator_chain TEXT NOT NULL,
        grade TEXT NOT NULL,
        tags TEXT NOT NULL,
        topics TEXT NOT NULL,
        reference TEXT,
        commentary TEXT NOT NULL,
        is_bookmarked INTEGER DEFAULT 0,
        bookmarked_at TEXT,
        cached_at TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE collections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        arabic_name TEXT NOT NULL,
        author TEXT NOT NULL,
        description TEXT NOT NULL,
        total_hadith INTEGER NOT NULL,
        total_books INTEGER NOT NULL,
        books TEXT NOT NULL,
        cover_image_url TEXT NOT NULL,
        available_languages TEXT NOT NULL,
        is_available_offline INTEGER DEFAULT 0,
        cached_at TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        arabic_name TEXT NOT NULL,
        description TEXT NOT NULL,
        hadith_count INTEGER NOT NULL,
        icon_name TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        hadith_id TEXT NOT NULL,
        collection TEXT NOT NULL,
        hadith_number TEXT NOT NULL,
        hadith_text TEXT NOT NULL,
        note TEXT,
        category TEXT DEFAULT 'General',
        tags TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT,
        FOREIGN KEY (hadith_id) REFERENCES hadiths (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_hadiths_collection ON hadiths(collection)');
    await db.execute('CREATE INDEX idx_hadiths_book ON hadiths(book)');
    await db.execute('CREATE INDEX idx_hadiths_bookmarked ON hadiths(is_bookmarked)');
    await db.execute('CREATE INDEX idx_bookmarks_hadith_id ON bookmarks(hadith_id)');
    await db.execute('CREATE INDEX idx_bookmarks_category ON bookmarks(category)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Cache hadiths locally
  Future<void> cacheHadiths(List<HadithModel> hadiths) async {
    final db = await database;
    final batch = db.batch();

    for (final hadith in hadiths) {
      batch.insert(
        'hadiths',
        {
          'id': hadith.id,
          'collection': hadith.collection,
          'book': hadith.book,
          'book_number': hadith.bookNumber,
          'hadith_number': hadith.hadithNumber,
          'chapter': hadith.chapter,
          'section': hadith.section,
          'arabic_text': hadith.arabicText,
          'translations': jsonEncode(hadith.translations),
          'narrator': hadith.narrator,
          'narrator_chain': hadith.narratorChain,
          'grade': hadith.grade.name,
          'tags': jsonEncode(hadith.tags),
          'topics': jsonEncode(hadith.topics),
          'reference': hadith.reference,
          'commentary': jsonEncode(hadith.commentary),
          'is_bookmarked': hadith.isBookmarked ? 1 : 0,
          'bookmarked_at': hadith.bookmarkedAt?.toIso8601String(),
          'cached_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  // Get cached hadiths
  Future<List<HadithModel>> getCachedHadiths({
    String? collection,
    String? book,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (collection != null) {
      whereClause += 'collection = ?';
      whereArgs.add(collection);
    }
    
    if (book != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'book = ?';
      whereArgs.add(book);
    }

    final result = await db.query(
      'hadiths',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      limit: limit,
      offset: offset,
      orderBy: 'hadith_number',
    );

    return result.map((map) => _hadithFromMap(map)).toList();
  }

  // Search cached hadiths
  Future<List<HadithModel>> searchCachedHadiths(String query) async {
    final db = await database;
    
    final result = await db.query(
      'hadiths',
      where: 'arabic_text LIKE ? OR translations LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'collection, hadith_number',
    );

    return result.map((map) => _hadithFromMap(map)).toList();
  }

  // Bookmark operations
  Future<void> bookmarkHadith(HadithModel hadith, {String? note, String category = 'General'}) async {
    final db = await database;
    
    await db.insert(
      'bookmarks',
      {
        'id': 'bookmark_${hadith.id}_${DateTime.now().millisecondsSinceEpoch}',
        'hadith_id': hadith.id,
        'collection': hadith.collection,
        'hadith_number': hadith.hadithNumber,
        'hadith_text': hadith.arabicText,
        'note': note,
        'category': category,
        'tags': jsonEncode(<String>[]),
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update hadith bookmark status
    await db.update(
      'hadiths',
      {
        'is_bookmarked': 1,
        'bookmarked_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [hadith.id],
    );
  }

  Future<void> removeBookmark(String hadithId) async {
    final db = await database;
    
    await db.delete(
      'bookmarks',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );

    // Update hadith bookmark status
    await db.update(
      'hadiths',
      {
        'is_bookmarked': 0,
        'bookmarked_at': null,
      },
      where: 'id = ?',
      whereArgs: [hadithId],
    );
  }

  Future<List<HadithBookmark>> getBookmarks() async {
    final db = await database;
    
    final result = await db.query(
      'bookmarks',
      orderBy: 'created_at DESC',
    );

    return result.map((map) => HadithBookmark.fromJson(map)).toList();
  }

  Future<bool> isBookmarked(String hadithId) async {
    final db = await database;
    
    final result = await db.query(
      'bookmarks',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Cache collections
  Future<void> cacheCollections(List<HadithCollection> collections) async {
    final db = await database;
    final batch = db.batch();

    for (final collection in collections) {
      batch.insert(
        'collections',
        {
          'id': collection.id,
          'name': collection.name,
          'arabic_name': collection.arabicName,
          'author': collection.author,
          'description': collection.description,
          'total_hadith': collection.totalHadith,
          'total_books': collection.totalBooks,
          'books': jsonEncode(collection.books.map((b) => b.toJson()).toList()),
          'cover_image_url': collection.coverImageUrl,
          'available_languages': jsonEncode(collection.availableLanguages),
          'is_available_offline': collection.isAvailableOffline ? 1 : 0,
          'cached_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<HadithCollection>> getCachedCollections() async {
    final db = await database;
    
    final result = await db.query(
      'collections',
      orderBy: 'name',
    );

    return result.map((map) => _collectionFromMap(map)).toList();
  }

  // Helper methods
  HadithModel _hadithFromMap(Map<String, dynamic> map) {
    return HadithModel(
      id: map['id'],
      collection: map['collection'],
      book: map['book'],
      bookNumber: map['book_number'],
      hadithNumber: map['hadith_number'],
      chapter: map['chapter'],
      section: map['section'],
      arabicText: map['arabic_text'],
      translations: Map<String, String>.from(jsonDecode(map['translations'])),
      narrator: map['narrator'],
      narratorChain: map['narrator_chain'],
      grade: HadithGrade.values.firstWhere((e) => e.name == map['grade']),
      tags: List<String>.from(jsonDecode(map['tags'])),
      topics: List<String>.from(jsonDecode(map['topics'])),
      reference: map['reference'],
      commentary: Map<String, String>.from(jsonDecode(map['commentary'])),
      isBookmarked: map['is_bookmarked'] == 1,
      bookmarkedAt: map['bookmarked_at'] != null ? DateTime.parse(map['bookmarked_at']) : null,
    );
  }

  HadithCollection _collectionFromMap(Map<String, dynamic> map) {
    return HadithCollection(
      id: map['id'],
      name: map['name'],
      arabicName: map['arabic_name'],
      author: map['author'],
      description: map['description'],
      totalHadith: map['total_hadith'],
      totalBooks: map['total_books'],
      books: (jsonDecode(map['books']) as List)
          .map((b) => HadithBook.fromJson(b))
          .toList(),
      coverImageUrl: map['cover_image_url'],
      availableLanguages: List<String>.from(jsonDecode(map['available_languages'])),
      isAvailableOffline: map['is_available_offline'] == 1,
    );
  }

  // Clear cache
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('hadiths');
    await db.delete('collections');
    await db.delete('categories');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
