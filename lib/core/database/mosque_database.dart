import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mosque/mosque_model.dart';
import '../models/mosque/mosque_review.dart';
import '../models/mosque/mosque_search.dart';
import '../models/location.dart';

class MosqueDatabase {
  static final MosqueDatabase _instance = MosqueDatabase._internal();
  factory MosqueDatabase() => _instance;
  MosqueDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mosque_finder.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Mosques table
    await db.execute('''
      CREATE TABLE mosques (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        location_address TEXT,
        location_city TEXT,
        location_country TEXT,
        phone_number TEXT,
        website TEXT,
        email TEXT,
        photos TEXT,
        facilities TEXT,
        prayer_times TEXT,
        rating REAL DEFAULT 0.0,
        review_count INTEGER DEFAULT 0,
        is_verified INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        description TEXT,
        type TEXT DEFAULT 'mosque',
        capacity INTEGER,
        imam TEXT,
        languages TEXT,
        status TEXT DEFAULT 'active',
        metadata TEXT,
        google_place_id TEXT,
        sync_status TEXT DEFAULT 'local'
      )
    ''');

    // Reviews table
    await db.execute('''
      CREATE TABLE mosque_reviews (
        id TEXT PRIMARY KEY,
        mosque_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_photo TEXT,
        rating REAL NOT NULL,
        comment TEXT,
        photos TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_verified INTEGER DEFAULT 0,
        helpful_count INTEGER DEFAULT 0,
        metadata TEXT,
        FOREIGN KEY (mosque_id) REFERENCES mosques (id) ON DELETE CASCADE
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorite_mosques (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mosque_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        UNIQUE(mosque_id, user_id),
        FOREIGN KEY (mosque_id) REFERENCES mosques (id) ON DELETE CASCADE
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        radius REAL,
        filters TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_mosques_location ON mosques (latitude, longitude)');
    await db.execute('CREATE INDEX idx_mosques_name ON mosques (name)');
    await db.execute('CREATE INDEX idx_mosques_rating ON mosques (rating DESC)');
    await db.execute('CREATE INDEX idx_reviews_mosque_id ON mosque_reviews (mosque_id)');
    await db.execute('CREATE INDEX idx_favorites_user_id ON favorite_mosques (user_id)');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  // Insert or update mosque
  Future<void> insertOrUpdateMosque(MosqueModel mosque) async {
    final db = await database;
    await db.insert(
      'mosques',
      mosque.toSQLiteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Batch insert mosques
  Future<void> insertMosques(List<MosqueModel> mosques) async {
    final db = await database;
    final batch = db.batch();
    
    for (final mosque in mosques) {
      batch.insert(
        'mosques',
        mosque.toSQLiteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Get mosque by ID
  Future<MosqueModel?> getMosqueById(String id) async {
    final db = await database;
    final results = await db.query(
      'mosques',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      final mosque = MosqueModel.fromSQLiteMap(results.first);
      final reviews = await getReviewsByMosqueId(id);
      return mosque.copyWith(reviews: reviews);
    }
    
    return null;
  }

  // Search nearby mosques
  Future<List<MosqueModel>> searchNearbyMosques({
    required Location location,
    double radiusKm = 10.0,
    String? query,
    MosqueSearchFilters? filters,
    MosqueSearchSort sortBy = MosqueSearchSort.distance,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;
    
    // Build query with spatial search
    String whereClause = _buildSpatialWhereClause(location, radiusKm);
    List<dynamic> whereArgs = [location.latitude, location.longitude];
    
    // Add text search
    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (name LIKE ? OR address LIKE ? OR description LIKE ?)';
      final queryPattern = '%$query%';
      whereArgs.addAll([queryPattern, queryPattern, queryPattern]);
    }
    
    // Add filters
    if (filters != null) {
      final filterClause = _buildFilterClause(filters);
      if (filterClause.isNotEmpty) {
        whereClause += ' AND $filterClause';
      }
    }
    
    // Build order clause
    String orderBy = _buildOrderClause(sortBy, location);
    
    final results = await db.query(
      'mosques',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return results.map((map) => MosqueModel.fromSQLiteMap(map)).toList();
  }

  // Get all favorite mosques
   Future<List<MosqueModel>> getFavoriteMosques(String userId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT m.* FROM mosques m
      INNER JOIN favorite_mosques f ON m.id = f.mosque_id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''', [userId]);

    return results.map((map) => MosqueModel.fromSQLiteMap(map)).toList();
  }

  // Add mosque to favorites
  Future<void> addToFavorites(String mosqueId, String userId) async {
    final db = await database;
    await db.insert(
      'favorite_mosques',
      {
        'mosque_id': mosqueId,
        'user_id': userId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Update mosque favorite status
    await db.update(
      'mosques',
      {'is_favorite': 1},
      where: 'id = ?',
      whereArgs: [mosqueId],
    );
  }

  // Remove mosque from favorites
  Future<void> removeFromFavorites(String mosqueId, String userId) async {
    final db = await database;
    await db.delete(
      'favorite_mosques',
      where: 'mosque_id = ? AND user_id = ?',
      whereArgs: [mosqueId, userId],
    );

    // Update mosque favorite status
    await db.update(
      'mosques',
      {'is_favorite': 0},
      where: 'id = ?',
      whereArgs: [mosqueId],
    );
  }

  // Check if mosque is favorite
  Future<bool> isFavorite(String mosqueId, String userId) async {
    final db = await database;
    final result = await db.query(
      'favorite_mosques',
      where: 'mosque_id = ? AND user_id = ?',
      whereArgs: [mosqueId, userId],
    );
    return result.isNotEmpty;
  }

  // Insert review
  Future<void> insertReview(MosqueReview review) async {
    final db = await database;
    await db.insert(
      'mosque_reviews',
      review.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update mosque rating and review count
    await _updateMosqueRating(review.mosqueId);
  }

  // Get reviews by mosque ID
  Future<List<MosqueReview>> getReviewsByMosqueId(String mosqueId) async {
    final db = await database;
    final results = await db.query(
      'mosque_reviews',
      where: 'mosque_id = ?',
      whereArgs: [mosqueId],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => MosqueReview.fromJson(map)).toList();
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    final db = await database;
    final review = await db.query(
      'mosque_reviews',
      where: 'id = ?',
      whereArgs: [reviewId],
    );

    if (review.isNotEmpty) {
      final mosqueId = review.first['mosque_id'] as String;
      
      await db.delete(
        'mosque_reviews',
        where: 'id = ?',
        whereArgs: [reviewId],
      );

      // Update mosque rating
      await _updateMosqueRating(mosqueId);
    }
  }

  // Update mosque rating and review count
  Future<void> _updateMosqueRating(String mosqueId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT AVG(rating) as avg_rating, COUNT(*) as review_count
      FROM mosque_reviews
      WHERE mosque_id = ?
    ''', [mosqueId]);

    if (result.isNotEmpty) {
      final avgRating = result.first['avg_rating'] as double? ?? 0.0;
      final reviewCount = result.first['review_count'] as int? ?? 0;

      await db.update(
        'mosques',
        {
          'rating': avgRating,
          'review_count': reviewCount,
        },
        where: 'id = ?',
        whereArgs: [mosqueId],
      );
    }
  }

  // Save search history
  Future<void> saveSearchHistory({
    required String query,
    Location? location,
    double? radius,
    MosqueSearchFilters? filters,
  }) async {
    final db = await database;
    await db.insert(
      'search_history',
      {
        'query': query,
        'latitude': location?.latitude,
        'longitude': location?.longitude,
        'radius': radius,
        'filters': filters != null ? jsonEncode(filters.toJson()) : null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Keep only last 50 searches
    await db.delete(
      'search_history',
      where: 'id NOT IN (SELECT id FROM search_history ORDER BY created_at DESC LIMIT 50)',
    );
  }

  // Get search history
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 10}) async {
    final db = await database;
    return await db.query(
      'search_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Delete mosque
  Future<void> deleteMosque(String id) async {
    final db = await database;
    await db.delete(
      'mosques',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('mosques');
    await db.delete('mosque_reviews');
    await db.delete('favorite_mosques');
    await db.delete('search_history');
  }

  // Helper method to build spatial where clause
  String _buildSpatialWhereClause(Location location, double radiusKm) {
    // Using Haversine formula approximation for SQLite
    // This is not 100% accurate but good enough for most use cases
    final latDiff = radiusKm / 111.0; // Approximate km per degree of latitude
    final lngDiff = radiusKm / (111.0 * math.cos(location.latitude * math.pi / 180));

    return '''
      latitude BETWEEN ? - $latDiff AND ? + $latDiff AND
      longitude BETWEEN longitude - $lngDiff AND longitude + $lngDiff
    ''';
  }

  // Helper method to build filter clause
  String _buildFilterClause(MosqueSearchFilters filters) {
    final conditions = <String>[];

    if (filters.hasParking == true) {
      conditions.add("json_extract(facilities, '\$.hasParking') = 1");
    }
    if (filters.hasWuduArea == true) {
      conditions.add("json_extract(facilities, '\$.hasWuduArea') = 1");
    }
    if (filters.hasWomenSection == true) {
      conditions.add("json_extract(facilities, '\$.hasWomenSection') = 1");
    }
    if (filters.hasWheelchairAccess == true) {
      conditions.add("json_extract(facilities, '\$.hasWheelchairAccess') = 1");
    }
    if (filters.hasAirConditioning == true) {
      conditions.add("json_extract(facilities, '\$.hasAirConditioning') = 1");
    }
    if (filters.hasLibrary == true) {
      conditions.add("json_extract(facilities, '\$.hasLibrary') = 1");
    }
    if (filters.hasQuranClasses == true) {
      conditions.add("json_extract(facilities, '\$.hasQuranClasses') = 1");
    }
    if (filters.hasArabicClasses == true) {
      conditions.add("json_extract(facilities, '\$.hasArabicClasses') = 1");
    }
    if (filters.minRating != null) {
      conditions.add("rating >= ${filters.minRating}");
    }
    if (filters.isVerified == true) {
      conditions.add("is_verified = 1");
    }
    if (filters.types != null && filters.types!.isNotEmpty) {
      final typeList = filters.types!.map((t) => "'${t.name}'").join(',');
      conditions.add("type IN ($typeList)");
    }

    return conditions.join(' AND ');
  }

  // Helper method to build order clause
  String _buildOrderClause(MosqueSearchSort sortBy, Location? location) {
    switch (sortBy) {
      case MosqueSearchSort.distance:
        if (location != null) {
          // Approximate distance calculation for ordering
          return '''
            ((latitude - ${location.latitude}) * (latitude - ${location.latitude}) + 
             (longitude - ${location.longitude}) * (longitude - ${location.longitude})) ASC
          ''';
        }
        return 'name ASC';
      case MosqueSearchSort.rating:
        return 'rating DESC, review_count DESC';
      case MosqueSearchSort.name:
        return 'name ASC';
      case MosqueSearchSort.newest:
        return 'created_at DESC';
      case MosqueSearchSort.mostReviewed:
        return 'review_count DESC, rating DESC';
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}