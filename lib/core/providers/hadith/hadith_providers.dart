import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/hadith/hadith_api_service.dart';
import 'package:islamia/core/services/hadith/hadith_database_service.dart';
import 'package:islamia/data/models/hadith/hadith_bookmark.dart';
import 'package:islamia/data/models/hadith/hadith_category.dart';
import 'package:islamia/data/models/hadith/hadith_collection.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
// Service providers
final hadithApiServiceProvider = Provider<HadithApiService>((ref) {
  return HadithApiService();
});

final hadithDatabaseServiceProvider = Provider<HadithDatabaseService>((ref) {
  return HadithDatabaseService();
});

// Collections provider
final hadithCollectionsProvider = FutureProvider<List<HadithCollection>>((ref) async {
  final apiService = ref.read(hadithApiServiceProvider);
  final dbService = ref.read(hadithDatabaseServiceProvider);
  
  try {
    // Try to get from API first
    final collections = await apiService.getCollections();
    // Cache the results
    await dbService.cacheCollections(collections);
    return collections;
  } catch (e) {
    // Fallback to cached data
    return await dbService.getCachedCollections();
  }
});

// Hadiths provider with family for collection and pagination
final hadithsProvider = FutureProvider.family<List<HadithModel>, HadithParams>((ref, params) async {
  final apiService = ref.read(hadithApiServiceProvider);
  final dbService = ref.read(hadithDatabaseServiceProvider);
  
  try {
    // Try to get from API first
    final hadiths = await apiService.getHadiths(
      collectionId: params.collectionId,
      bookId: params.bookId,
      chapterId: params.chapterId,
      page: params.page,
      limit: params.limit,
      language: params.language,
    );
    
    // Cache the results
    await dbService.cacheHadiths(hadiths);
    return hadiths;
  } catch (e) {
    // Fallback to cached data
    return await dbService.getCachedHadiths(
      collection: params.collectionId,
      book: params.bookId,
      limit: params.limit,
      offset: (params.page - 1) * params.limit,
    );
  }
});

// Search provider
final hadithSearchProvider = FutureProvider.family<List<HadithModel>, SearchParams>((ref, params) async {
  if (params.query.isEmpty || params.query.length < 3) return [];
  
  final apiService = ref.read(hadithApiServiceProvider);
  final dbService = ref.read(hadithDatabaseServiceProvider);
  
  try {
    // Try API search first
    final results = await apiService.searchHadiths(
      query: params.query,
      collectionId: params.collectionId,
      language: params.language,
      page: params.page,
      limit: params.limit,
    );
    return results;
  } catch (e) {
    // Fallback to local search
    return await dbService.searchCachedHadiths(params.query);
  }
});

// Categories provider
final hadithCategoriesProvider = FutureProvider<List<HadithCategory>>((ref) async {
  final apiService = ref.read(hadithApiServiceProvider);
  return await apiService.getCategories();
});

// Category hadiths provider
final categoryHadithsProvider = FutureProvider.family<List<HadithModel>, CategoryParams>((ref, params) async {
  final apiService = ref.read(hadithApiServiceProvider);
  return await apiService.getHadithsByCategory(
    category: params.categoryId,
    language: params.language,
    page: params.page,
    limit: params.limit,
  );
});

// Daily hadith provider
final dailyHadithProvider = FutureProvider<HadithModel>((ref) async {
  final apiService = ref.read(hadithApiServiceProvider);
  return await apiService.getRandomHadith();
});

// Bookmarks provider
final hadithBookmarksProvider = StateNotifierProvider<HadithBookmarksNotifier, List<HadithBookmark>>((ref) {
  return HadithBookmarksNotifier(ref.read(hadithDatabaseServiceProvider));
});

// Parameter classes
class HadithParams {
  final String collectionId;
  final String? bookId;
  final String? chapterId;
  final int page;
  final int limit;
  final String language;

  const HadithParams({
    required this.collectionId,
    this.bookId,
    this.chapterId,
    this.page = 1,
    this.limit = 20,
    this.language = 'en',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithParams &&
          runtimeType == other.runtimeType &&
          collectionId == other.collectionId &&
          bookId == other.bookId &&
          chapterId == other.chapterId &&
          page == other.page &&
          limit == other.limit &&
          language == other.language;

  @override
  int get hashCode => Object.hash(collectionId, bookId, chapterId, page, limit, language);
}

class SearchParams {
  final String query;
  final String? collectionId;
  final String language;
  final int page;
  final int limit;

  const SearchParams({
    required this.query,
    this.collectionId,
    this.language = 'en',
    this.page = 1,
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          collectionId == other.collectionId &&
          language == other.language &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(query, collectionId, language, page, limit);
}

class CategoryParams {
  final String categoryId;
  final String language;
  final int page;
  final int limit;

  const CategoryParams({
    required this.categoryId,
    this.language = 'en',
    this.page = 1,
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryParams &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          language == other.language &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(categoryId, language, page, limit);
}

// Bookmarks notifier
class HadithBookmarksNotifier extends StateNotifier<List<HadithBookmark>> {
  final HadithDatabaseService _dbService;

  HadithBookmarksNotifier(this._dbService) : super([]) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _dbService.getBookmarks();
    state = bookmarks;
  }

  Future<void> addBookmark(HadithModel hadith, {String? note, String category = 'General'}) async {
    await _dbService.bookmarkHadith(hadith, note: note, category: category);
    await _loadBookmarks();
  }

  Future<void> removeBookmark(String hadithId) async {
    await _dbService.removeBookmark(hadithId);
    await _loadBookmarks();
  }

  Future<bool> isBookmarked(String hadithId) async {
    return await _dbService.isBookmarked(hadithId);
  }

  Future<void> refresh() async {
    await _loadBookmarks();
  }
}