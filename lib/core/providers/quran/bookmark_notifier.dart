import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/bookmark_provider.dart';
import 'package:islamia/core/services/quran/bookmark_service.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';

// Bookmark State

class BookmarkState {
  final List<BookmarkModel> bookmarks;
  final bool isLoading;
  final String? error;
  final Map<String, List<BookmarkModel>> categorizedBookmarks;
  final List<String> categories;
  final List<String> tags;
  
  // Statistics fields (merged from BookmarkServiceStats)
  final Map<String, int> categoryDistribution;
  final Map<String, int> tagDistribution;
  final BookmarkModel? oldestBookmark;
  final BookmarkModel? newestBookmark;
  final double averageBookmarksPerSurah;

  const BookmarkState({
    this.bookmarks = const [],
    this.isLoading = false,
    this.error,
    this.categorizedBookmarks = const {},
    this.categories = const [],
    this.tags = const [],
    this.categoryDistribution = const {},
    this.tagDistribution = const {},
    this.oldestBookmark,
    this.newestBookmark,
    this.averageBookmarksPerSurah = 0.0,
  });

  BookmarkState copyWith({
    List<BookmarkModel>? bookmarks,
    bool? isLoading,
    String? error,
    Map<String, List<BookmarkModel>>? categorizedBookmarks,
    List<String>? categories,
    List<String>? tags,
    Map<String, int>? categoryDistribution,
    Map<String, int>? tagDistribution,
    BookmarkModel? oldestBookmark,
    BookmarkModel? newestBookmark,
    double? averageBookmarksPerSurah,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categorizedBookmarks: categorizedBookmarks ?? this.categorizedBookmarks,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      tagDistribution: tagDistribution ?? this.tagDistribution,
      oldestBookmark: oldestBookmark ?? this.oldestBookmark,
      newestBookmark: newestBookmark ?? this.newestBookmark,
      averageBookmarksPerSurah: averageBookmarksPerSurah ?? this.averageBookmarksPerSurah,
    );
  }

  // Factory constructor to create state from BookmarkServiceStats
  factory BookmarkState.fromStats({
    required List<BookmarkModel> bookmarks,
    required Map<String, List<BookmarkModel>> categorizedBookmarks,
    required List<String> categories,
    required List<String> tags,
    required Map<String, int> categoryDistribution,
    required Map<String, int> tagDistribution,
    BookmarkModel? oldestBookmark,
    BookmarkModel? newestBookmark,
    required double averageBookmarksPerSurah,
    bool isLoading = false,
    String? error,
  }) {
    return BookmarkState(
      bookmarks: bookmarks,
      isLoading: isLoading,
      error: error,
      categorizedBookmarks: categorizedBookmarks,
      categories: categories,
      tags: tags,
      categoryDistribution: categoryDistribution,
      tagDistribution: tagDistribution,
      oldestBookmark: oldestBookmark,
      newestBookmark: newestBookmark,
      averageBookmarksPerSurah: averageBookmarksPerSurah,
    );
  }

  // Basic getters
  int get totalBookmarks => bookmarks.length;
  bool get hasBookmarks => bookmarks.isNotEmpty;
  bool get hasError => error != null;
  int get categoriesCount => categories.length;
  int get tagsCount => tags.length;

  // Statistics getters (merged from BookmarkServiceStats)
  int get surahsWithBookmarks {
    return bookmarks.map((b) => b.surahNumber).toSet().length;
  }

  Duration? get bookmarkingDuration {
    if (oldestBookmark == null || newestBookmark == null) return null;
    return newestBookmark!.createdAt.difference(oldestBookmark!.createdAt);
  }

  String get mostUsedCategory {
    if (categoryDistribution.isEmpty) return 'None';
    return categoryDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get mostUsedTag {
    if (tagDistribution.isEmpty) return 'None';
    return tagDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Get bookmarks by category
  List<BookmarkModel> getBookmarksByCategory(String category) {
    return categorizedBookmarks[category] ?? [];
  }

  // Get bookmarks by tag
  List<BookmarkModel> getBookmarksByTag(String tag) {
    return bookmarks.where((bookmark) => bookmark.tags.contains(tag)).toList();
  }

  // Get bookmarks by surah
  List<BookmarkModel> getBookmarksBySurah(int surahNumber) {
    return bookmarks
        .where((bookmark) => bookmark.surahNumber == surahNumber)
        .toList();
  }

  // Check if ayah is bookmarked
  bool isAyahBookmarked(int surahNumber, int ayahNumber) {
    return bookmarks.any(
      (bookmark) => 
          bookmark.surahNumber == surahNumber && 
          bookmark.ayahNumber == ayahNumber,
    );
  }

  // Get bookmark for specific ayah
  BookmarkModel? getBookmarkForAyah(int surahNumber, int ayahNumber) {
    try {
      return bookmarks.firstWhere(
        (bookmark) => 
            bookmark.surahNumber == surahNumber && 
            bookmark.ayahNumber == ayahNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // Search bookmarks
  List<BookmarkModel> searchBookmarks(String query) {
    if (query.isEmpty) return bookmarks;
    
    final lowercaseQuery = query.toLowerCase();
    return bookmarks.where((bookmark) {
      return bookmark.surahName.toLowerCase().contains(lowercaseQuery) ||
             bookmark.ayahText.toLowerCase().contains(lowercaseQuery) ||
             bookmark.note?.toLowerCase().contains(lowercaseQuery) == true ||
             bookmark.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Get recent bookmarks
  List<BookmarkModel> getRecentBookmarks({int limit = 10}) {
    final sortedBookmarks = [...bookmarks];
    sortedBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedBookmarks.take(limit).toList();
  }

  // Get bookmarks by date range
  List<BookmarkModel> getBookmarksByDateRange(DateTime start, DateTime end) {
    return bookmarks.where((bookmark) {
      return bookmark.createdAt.isAfter(start) && bookmark.createdAt.isBefore(end);
    }).toList();
  }

  // Get category with most bookmarks
  String get categoryWithMostBookmarks {
    if (categoryDistribution.isEmpty) return 'None';
    return categoryDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Get tag with most bookmarks
  String get tagWithMostBookmarks {
    if (tagDistribution.isEmpty) return 'None';
    return tagDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Get bookmarks count for a specific category
  int getBookmarkCountForCategory(String category) {
    return categoryDistribution[category] ?? 0;
  }

  // Get bookmarks count for a specific tag
  int getBookmarkCountForTag(String tag) {
    return tagDistribution[tag] ?? 0;
  }

  // Check if state is empty (no bookmarks)
  bool get isEmpty => bookmarks.isEmpty;

  // Check if state has statistics
  bool get hasStatistics => 
      categoryDistribution.isNotEmpty || 
      tagDistribution.isNotEmpty;

  // Get bookmarking activity summary
  String get activitySummary {
    if (isEmpty) return 'No bookmarks yet';
    
    final duration = bookmarkingDuration;
    if (duration == null) return 'Single bookmark session';
    
    final days = duration.inDays;
    final months = days ~/ 30;
    
    if (months > 0) {
      return 'Bookmarking for $months months ($totalBookmarks bookmarks)';
    } else if (days > 0) {
      return 'Bookmarking for $days days ($totalBookmarks bookmarks)';
    } else {
      return 'Recent bookmarking session ($totalBookmarks bookmarks)';
    }
  }

  // Convert to JSON (for serialization/debugging)
  Map<String, dynamic> toJson() {
    return {
      'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
      'isLoading': isLoading,
      'error': error,
      'categories': categories,
      'tags': tags,
      'totalBookmarks': totalBookmarks,
      'categoriesCount': categoriesCount,
      'surahsWithBookmarks': surahsWithBookmarks,
      'categoryDistribution': categoryDistribution,
      'tagDistribution': tagDistribution,
      'averageBookmarksPerSurah': averageBookmarksPerSurah,
      'oldestBookmark': oldestBookmark?.toJson(),
      'newestBookmark': newestBookmark?.toJson(),
      'mostUsedCategory': mostUsedCategory,
      'mostUsedTag': mostUsedTag,
    };
  }

  // Factory constructor from JSON
  factory BookmarkState.fromJson(Map<String, dynamic> json) {
    final bookmarksList = (json['bookmarks'] as List? ?? [])
        .map((b) => BookmarkModel.fromJson(b))
        .toList();

    // Rebuild categorized bookmarks
    final Map<String, List<BookmarkModel>> categorizedBookmarks = {};
    final categories = List<String>.from(json['categories'] ?? []);
    
    for (final category in categories) {
      categorizedBookmarks[category] = bookmarksList
          .where((bookmark) => bookmark.category == category)
          .toList();
    }

    return BookmarkState(
      bookmarks: bookmarksList,
      isLoading: json['isLoading'] ?? false,
      error: json['error'],
      categorizedBookmarks: categorizedBookmarks,
      categories: categories,
      tags: List<String>.from(json['tags'] ?? []),
      categoryDistribution: Map<String, int>.from(json['categoryDistribution'] ?? {}),
      tagDistribution: Map<String, int>.from(json['tagDistribution'] ?? {}),
      averageBookmarksPerSurah: (json['averageBookmarksPerSurah'] ?? 0.0).toDouble(),
      oldestBookmark: json['oldestBookmark'] != null 
          ? BookmarkModel.fromJson(json['oldestBookmark'])
          : null,
      newestBookmark: json['newestBookmark'] != null 
          ? BookmarkModel.fromJson(json['newestBookmark'])
          : null,
    );
  }

  @override
  String toString() {
    return 'BookmarkState(bookmarks: ${bookmarks.length}, '
           'categories: ${categories.length}, '
           'tags: ${tags.length}, '
           'isLoading: $isLoading, '
           'hasError: $hasError)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookmarkState &&
        other.bookmarks.length == bookmarks.length &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.categories.length == categories.length &&
        other.tags.length == tags.length;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookmarks.length,
      isLoading,
      error,
      categories.length,
      tags.length,
    );
  }
}

// Helper extension for additional functionality
extension BookmarkStateExtension on BookmarkState {
  // Get bookmarks grouped by surah
  Map<int, List<BookmarkModel>> get bookmarksBySurah {
    final Map<int, List<BookmarkModel>> grouped = {};
    for (final bookmark in bookmarks) {
      grouped.putIfAbsent(bookmark.surahNumber, () => []).add(bookmark);
    }
    return grouped;
  }

  // Get bookmarks statistics as a separate object (for backward compatibility)
  BookmarkServiceStats get stats {
    return BookmarkServiceStats(
      totalBookmarks: totalBookmarks,
      categoriesCount: categoriesCount,
      surahsWithBookmarks: surahsWithBookmarks,
      categoryDistribution: categoryDistribution,
      tagDistribution: tagDistribution,
      oldestBookmark: oldestBookmark,
      newestBookmark: newestBookmark,
      averageBookmarksPerSurah: averageBookmarksPerSurah,
    );
  }
}

// Keep BookmarkServiceStats for backward compatibility if needed
class BookmarkServiceStats {
  final int totalBookmarks;
  final int categoriesCount;
  final int surahsWithBookmarks;
  final Map<String, int> categoryDistribution;
  final Map<String, int> tagDistribution;
  final BookmarkModel? oldestBookmark;
  final BookmarkModel? newestBookmark;
  final double averageBookmarksPerSurah;

  BookmarkServiceStats({
    required this.totalBookmarks,
    required this.categoriesCount,
    required this.surahsWithBookmarks,
    required this.categoryDistribution,
    required this.tagDistribution,
    this.oldestBookmark,
    this.newestBookmark,
    required this.averageBookmarksPerSurah,
  });

  // Create from BookmarkState
  factory BookmarkServiceStats.fromBookmarkState(BookmarkState state) {
    return BookmarkServiceStats(
      totalBookmarks: state.totalBookmarks,
      categoriesCount: state.categoriesCount,
      surahsWithBookmarks: state.surahsWithBookmarks,
      categoryDistribution: state.categoryDistribution,
      tagDistribution: state.tagDistribution,
      oldestBookmark: state.oldestBookmark,
      newestBookmark: state.newestBookmark,
      averageBookmarksPerSurah: state.averageBookmarksPerSurah,
    );
  }

  Duration? get bookmarkingDuration {
    if (oldestBookmark == null || newestBookmark == null) return null;
    return newestBookmark!.createdAt.difference(oldestBookmark!.createdAt);
  }

  String get mostUsedCategory {
    if (categoryDistribution.isEmpty) return 'None';
    return categoryDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get mostUsedTag {
    if (tagDistribution.isEmpty) return 'None';
    return tagDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBookmarks': totalBookmarks,
      'categoriesCount': categoriesCount,
      'surahsWithBookmarks': surahsWithBookmarks,
      'categoryDistribution': categoryDistribution,
      'tagDistribution': tagDistribution,
      'averageBookmarksPerSurah': averageBookmarksPerSurah,
      'oldestBookmark': oldestBookmark?.toJson(),
      'newestBookmark': newestBookmark?.toJson(),
    };
  }

  factory BookmarkServiceStats.fromJson(Map<String, dynamic> json) {
    return BookmarkServiceStats(
      totalBookmarks: json['totalBookmarks'] ?? 0,
      categoriesCount: json['categoriesCount'] ?? 0,
      surahsWithBookmarks: json['surahsWithBookmarks'] ?? 0,
      categoryDistribution: Map<String, int>.from(json['categoryDistribution'] ?? {}),
      tagDistribution: Map<String, int>.from(json['tagDistribution'] ?? {}),
      averageBookmarksPerSurah: (json['averageBookmarksPerSurah'] ?? 0.0).toDouble(),
      oldestBookmark: json['oldestBookmark'] != null 
          ? BookmarkModel.fromJson(json['oldestBookmark'])
          : null,
      newestBookmark: json['newestBookmark'] != null 
          ? BookmarkModel.fromJson(json['newestBookmark'])
          : null,
    );
  }
}
// Bookmark Notifier
class BookmarkNotifier extends StateNotifier<BookmarkState> {
  final BookmarkService _bookmarkService;

  BookmarkNotifier(this._bookmarkService) : super(const BookmarkState()) {
    _initialize();
  }

  // Initialize and load bookmarks
  Future<void> _initialize() async {
    await loadBookmarks();
  }

  bool isBookmarked(BookmarkModel ayah) {
  return state.bookmarks.any((b) =>
      b.surahNumber == ayah.surahNumber &&
      b.ayahNumber == ayah.ayahNumber);
}

  // Load all bookmarks
  Future<void> loadBookmarks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Load bookmarks and metadata concurrently
      final results = await Future.wait([
        _bookmarkService.getAllBookmarks(),
        _bookmarkService.getAllCategories(),
        _bookmarkService.getAllTags(),
      ]);

      final bookmarks = results[0] as List<BookmarkModel>;
      final categories = results[1] as List<String>;
      final tags = results[2] as List<String>;

      // Categorize bookmarks
      final categorizedBookmarks = <String, List<BookmarkModel>>{};
      for (final category in categories) {
        categorizedBookmarks[category] = bookmarks
            .where((bookmark) => bookmark.category == category)
            .toList();
      }

      state = state.copyWith(
        bookmarks: bookmarks,
        categories: categories,
        tags: tags,
        categorizedBookmarks: categorizedBookmarks,
        isLoading: false,
        error: null,
      );

      debugPrint('Loaded ${bookmarks.length} bookmarks');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load bookmarks: $e',
      );
      debugPrint('Error loading bookmarks: $e');
    }
  }

  // Add bookmark
  Future<bool> addBookmark(BookmarkModel bookmark) async {
    try {
      // Check if bookmark already exists
      if (state.isAyahBookmarked(bookmark.surahNumber, bookmark.ayahNumber)) {
        state = state.copyWith(error: 'Bookmark already exists for this ayah');
        return false;
      }

      // Add bookmark to service
      final newBookmark = await _bookmarkService.addBookmark(bookmark);
      
      // Update state
      final updatedBookmarks = [...state.bookmarks, newBookmark];
      await _updateStateAfterChange(updatedBookmarks);
      
      debugPrint('Added bookmark: ${newBookmark.id}');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add bookmark: $e');
      debugPrint('Error adding bookmark: $e');
      return false;
    }
  }

  // Remove bookmark by ID
  Future<bool> removeBookmark(String bookmarkId) async {
    try {
      await _bookmarkService.removeBookmark(bookmarkId);
      
      // Update state
      final updatedBookmarks = state.bookmarks
          .where((bookmark) => bookmark.id != bookmarkId)
          .toList();
      await _updateStateAfterChange(updatedBookmarks);
      
      debugPrint('Removed bookmark: $bookmarkId');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove bookmark: $e');
      debugPrint('Error removing bookmark: $e');
      return false;
    }
  }

  // Remove bookmark by ayah
  Future<bool> removeBookmarkByAyah(int surahNumber, int ayahNumber) async {
    try {
      await _bookmarkService.removeBookmarkByAyah(surahNumber, ayahNumber);
      
      // Update state
      final updatedBookmarks = state.bookmarks
          .where((bookmark) => 
              !(bookmark.surahNumber == surahNumber && 
                bookmark.ayahNumber == ayahNumber))
          .toList();
      await _updateStateAfterChange(updatedBookmarks);
      
      debugPrint('Removed bookmark for ayah: $surahNumber:$ayahNumber');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove bookmark: $e');
      debugPrint('Error removing bookmark by ayah: $e');
      return false;
    }
  }

  // Update bookmark
  Future<bool> updateBookmark(BookmarkModel bookmark) async {
    try {
      final updatedBookmark = await _bookmarkService.updateBookmark(bookmark);
      
      // Update state
      final updatedBookmarks = state.bookmarks
          .map((b) => b.id == bookmark.id ? updatedBookmark : b)
          .toList();
      await _updateStateAfterChange(updatedBookmarks);
      
      debugPrint('Updated bookmark: ${bookmark.id}');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update bookmark: $e');
      debugPrint('Error updating bookmark: $e');
      return false;
    }
  }

  // Toggle bookmark (add if doesn't exist, remove if exists)
  Future<bool> toggleBookmark(BookmarkModel bookmark) async {
    try {
      final isBookmarked = state.isAyahBookmarked(
        bookmark.surahNumber, 
        bookmark.ayahNumber
      );

      if (isBookmarked) {
        return await removeBookmarkByAyah(
          bookmark.surahNumber, 
          bookmark.ayahNumber
        );
      } else {
        return await addBookmark(bookmark);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle bookmark: $e');
      debugPrint('Error toggling bookmark: $e');
      return false;
    }
  }

  // Move bookmark to different category
  Future<bool> moveBookmarkToCategory(String bookmarkId, String newCategory) async {
    try {
      final bookmark = state.bookmarks.firstWhere((b) => b.id == bookmarkId);
      final updatedBookmark = bookmark.copyWith(category: newCategory);
      
      return await updateBookmark(updatedBookmark);
    } catch (e) {
      state = state.copyWith(error: 'Failed to move bookmark: $e');
      debugPrint('Error moving bookmark: $e');
      return false;
    }
  }

  // Add tag to bookmark
  Future<bool> addTagToBookmark(String bookmarkId, String tag) async {
    try {
      final bookmark = state.bookmarks.firstWhere((b) => b.id == bookmarkId);
      if (bookmark.tags.contains(tag)) return true;
      
      final updatedTags = [...bookmark.tags, tag];
      final updatedBookmark = bookmark.copyWith(tags: updatedTags);
      
      return await updateBookmark(updatedBookmark);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add tag: $e');
      debugPrint('Error adding tag: $e');
      return false;
    }
  }

  // Remove tag from bookmark
  Future<bool> removeTagFromBookmark(String bookmarkId, String tag) async {
    try {
      final bookmark = state.bookmarks.firstWhere((b) => b.id == bookmarkId);
      final updatedTags = bookmark.tags.where((t) => t != tag).toList();
      final updatedBookmark = bookmark.copyWith(tags: updatedTags);
      
      return await updateBookmark(updatedBookmark);
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove tag: $e');
      debugPrint('Error removing tag: $e');
      return false;
    }
  }

  // Update bookmark note
  Future<bool> updateBookmarkNote(String bookmarkId, String? note) async {
    try {
      final bookmark = state.bookmarks.firstWhere((b) => b.id == bookmarkId);
      final updatedBookmark = bookmark.copyWith(note: note);
      
      return await updateBookmark(updatedBookmark);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update note: $e');
      debugPrint('Error updating note: $e');
      return false;
    }
  }

  // Clear all bookmarks
  Future<bool> clearAllBookmarks() async {
    try {
      await _bookmarkService.clearAllBookmarks();
      
      state = state.copyWith(
        bookmarks: [],
        categorizedBookmarks: {},
        categories: [],
        tags: [],
        error: null,
      );
      
      debugPrint('Cleared all bookmarks');
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear bookmarks: $e');
      debugPrint('Error clearing bookmarks: $e');
      return false;
    }
  }

  // Import bookmarks
  Future<ImportResult> importBookmarks(String jsonData, {bool overwrite = false}) async {
    try {
      final result = await _bookmarkService.importBookmarks(jsonData, overwrite: overwrite);
      
      if (result.success) {
        await loadBookmarks(); // Refresh state
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Failed to import bookmarks: $e');
      return ImportResult(
        success: false,
        imported: 0,
        skipped: 0,
        message: 'Import failed: $e',
      );
    }
  }

  // Export bookmarks
  Future<String?> exportBookmarks() async {
    try {
      return await _bookmarkService.exportBookmarks();
    } catch (e) {
      state = state.copyWith(error: 'Failed to export bookmarks: $e');
      debugPrint('Error exporting bookmarks: $e');
      return null;
    }
  }

  // Get bookmark statistics
  Future<BookmarkServiceStats?> getBookmarkStats() async {
    try {
      return await _bookmarkService.getBookmarkStats();
    } catch (e) {
      state = state.copyWith(error: 'Failed to get stats: $e');
      debugPrint('Error getting bookmark stats: $e');
      return null;
    }
  }

  // Refresh bookmarks
  Future<void> refresh() async {
    await loadBookmarks();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper method to update state after changes
  Future<void> _updateStateAfterChange(List<BookmarkModel> updatedBookmarks) async {
    try {
      // Update categories and tags
      final categories = await _bookmarkService.getAllCategories();
      final tags = await _bookmarkService.getAllTags();

      // Recategorize bookmarks
      final categorizedBookmarks = <String, List<BookmarkModel>>{};
      for (final category in categories) {
        categorizedBookmarks[category] = updatedBookmarks
            .where((bookmark) => bookmark.category == category)
            .toList();
      }

      state = state.copyWith(
        bookmarks: updatedBookmarks,
        categories: categories,
        tags: tags,
        categorizedBookmarks: categorizedBookmarks,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update state: $e');
    }
  }





  
}






// Provider for BookmarkNotifier
final bookmarkNotifierProvider = StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  final bookmarkService = ref.read(bookmarkServiceProvider);
  return BookmarkNotifier(bookmarkService);
});

// Derived providers for specific use cases
final bookmarksByCategory = Provider.family<List<BookmarkModel>, String>((ref, category) {
  final bookmarkState = ref.watch(bookmarkNotifierProvider);
  return bookmarkState.getBookmarksByCategory(category);
});

final bookmarksBySurah = Provider.family<List<BookmarkModel>, int>((ref, surahNumber) {
  final bookmarkState = ref.watch(bookmarkNotifierProvider);
  return bookmarkState.getBookmarksBySurah(surahNumber);
});

final isAyahBookmarked = Provider.family<bool, AyahReference>((ref, ayahRef) {
  final bookmarkState = ref.watch(bookmarkNotifierProvider);
  return bookmarkState.isAyahBookmarked(ayahRef.surahNumber, ayahRef.ayahNumber);
});

final bookmarkSearch = Provider.family<List<BookmarkModel>, String>((ref, query) {
  final bookmarkState = ref.watch(bookmarkNotifierProvider);
  return bookmarkState.searchBookmarks(query);
});

final recentBookmarks = Provider<List<BookmarkModel>>((ref) {
  final bookmarkState = ref.watch(bookmarkNotifierProvider);
  final sortedBookmarks = [...bookmarkState.bookmarks];
  sortedBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedBookmarks.take(10).toList();
});

// Helper class for ayah reference
class AyahReference {
  final int surahNumber;
  final int ayahNumber;

  const AyahReference({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahReference &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);
}