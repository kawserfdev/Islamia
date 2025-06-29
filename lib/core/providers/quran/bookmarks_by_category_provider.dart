import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/quran/bookmark_service.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';

// Define bookmark categories as enum to match your model
enum BookmarkCategory {
  general('General'),
  favorites('Favorites'),
  toRead('To Read'),
  important('Important'),
  memorization('Memorization'),
  reflection('Reflection');

  const BookmarkCategory(this.displayName);
  final String displayName;

  static BookmarkCategory fromString(String category) {
    return BookmarkCategory.values.firstWhere(
      (e) => e.displayName == category,
      orElse: () => BookmarkCategory.general,
    );
  }
}

// Main provider for bookmarks grouped by category
final bookmarksByCategoryProvider = StateNotifierProvider<BookmarksByCategoryNotifier, Map<BookmarkCategory, List<BookmarkModel>>>(
  (ref) => BookmarksByCategoryNotifier(ref.read(bookmarkServiceProvider)),
);

class BookmarksByCategoryNotifier extends StateNotifier<Map<BookmarkCategory, List<BookmarkModel>>> {
  final BookmarkService _bookmarkService;

  BookmarksByCategoryNotifier(this._bookmarkService) : super({}) {
    _loadBookmarks();
  }

  // Load all bookmarks and group by category
  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await _bookmarkService.getAllBookmarks();
      final groupedBookmarks = <BookmarkCategory, List<BookmarkModel>>{};

      // Initialize all categories
      for (final category in BookmarkCategory.values) {
        groupedBookmarks[category] = [];
      }

      // Group bookmarks by category
      for (final bookmark in bookmarks) {
        final category = BookmarkCategory.fromString(bookmark.category);
        groupedBookmarks[category]!.add(bookmark);
      }

      // Sort bookmarks within each category by creation date (newest first)
      for (final category in groupedBookmarks.keys) {
        groupedBookmarks[category]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      state = groupedBookmarks;
    } catch (e) {
      // Handle error - could set an error state or log
      print('Error loading bookmarks: $e');
    }
  }

  // Add a new bookmark
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      // Generate ID if not provided
      final newBookmark = bookmark.id.isEmpty
          ? bookmark.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              createdAt: DateTime.now(),
            )
          : bookmark;
      
      final savedBookmark = await _bookmarkService.addBookmark(newBookmark);
      
      final updatedState = Map<BookmarkCategory, List<BookmarkModel>>.from(state);
      final category = BookmarkCategory.fromString(savedBookmark.category);
      
      if (!updatedState.containsKey(category)) {
        updatedState[category] = [];
      }
      
      updatedState[category]!.insert(0, savedBookmark);
      state = updatedState;
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  // Remove a bookmark
  Future<void> removeBookmark(String bookmarkId) async {
    try {
      await _bookmarkService.removeBookmark(bookmarkId);
      
      final updatedState = Map<BookmarkCategory, List<BookmarkModel>>.from(state);
      
      for (final category in updatedState.keys) {
        updatedState[category]!.removeWhere((bookmark) => bookmark.id == bookmarkId);
      }
      
      state = updatedState;
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  // Update a bookmark
  Future<void> updateBookmark(BookmarkModel updatedBookmark) async {
    try {
      final savedBookmark = await _bookmarkService.updateBookmark(updatedBookmark);
      
      final updatedState = Map<BookmarkCategory, List<BookmarkModel>>.from(state);
      
      // Remove from all categories first
      for (final category in updatedState.keys) {
        updatedState[category]!.removeWhere((bookmark) => bookmark.id == savedBookmark.id);
      }
      
      // Add to correct category
      final newCategory = BookmarkCategory.fromString(savedBookmark.category);
      if (!updatedState.containsKey(newCategory)) {
        updatedState[newCategory] = [];
      }
      
      // Insert in correct position (by date)
      final categoryList = updatedState[newCategory]!;
      int insertIndex = 0;
      for (int i = 0; i < categoryList.length; i++) {
        if (savedBookmark.createdAt.isAfter(categoryList[i].createdAt)) {
          insertIndex = i;
          break;
        }
        insertIndex = i + 1;
      }
      
      categoryList.insert(insertIndex, savedBookmark);
      state = updatedState;
    } catch (e) {
      throw Exception('Failed to update bookmark: $e');
    }
  }

  // Move bookmark to different category
  Future<void> moveBookmarkToCategory(String bookmarkId, BookmarkCategory newCategory) async {
    try {
      final bookmark = getBookmarkById(bookmarkId);
      if (bookmark == null) return;

      final updatedBookmark = bookmark.copyWith(
        category: newCategory.displayName,
      );

      await updateBookmark(updatedBookmark);
    } catch (e) {
      throw Exception('Failed to move bookmark: $e');
    }
  }

  // Get bookmark by ID
  BookmarkModel? getBookmarkById(String bookmarkId) {
    for (final bookmarks in state.values) {
      for (final bookmark in bookmarks) {
        if (bookmark.id == bookmarkId) {
          return bookmark;
        }
      }
    }
    return null;
  }

  // Get bookmarks for specific category
  List<BookmarkModel> getBookmarksForCategory(BookmarkCategory category) {
    return state[category] ?? [];
  }

  // Get total bookmark count
  int get totalBookmarkCount {
    return state.values.fold(0, (sum, bookmarks) => sum + bookmarks.length);
  }

  // Get bookmark count for specific category
  int getBookmarkCountForCategory(BookmarkCategory category) {
    return state[category]?.length ?? 0;
  }

  // Search bookmarks across all categories
  List<BookmarkModel> searchBookmarks(String query) {
    if (query.isEmpty) return [];
    
    final results = <BookmarkModel>[];
    final lowerQuery = query.toLowerCase();
    
    for (final bookmarks in state.values) {
      for (final bookmark in bookmarks) {
        if (bookmark.surahName.toLowerCase().contains(lowerQuery) ||
            bookmark.ayahText.toLowerCase().contains(lowerQuery) ||
            bookmark.note?.toLowerCase().contains(lowerQuery) == true ||
            bookmark.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
          results.add(bookmark);
        }
      }
    }
    
    return results;
  }

  // Get recent bookmarks (last 10)
  List<BookmarkModel> getRecentBookmarks({int limit = 10}) {
    final allBookmarks = <BookmarkModel>[];
    
    for (final bookmarks in state.values) {
      allBookmarks.addAll(bookmarks);
    }
    
    allBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return allBookmarks.take(limit).toList();
  }

  // Get bookmarks by Surah
  List<BookmarkModel> getBookmarksBySurah(int surahNumber) {
    final allBookmarks = <BookmarkModel>[];
    
    for (final bookmarks in state.values) {
      allBookmarks.addAll(bookmarks.where((b) => b.surahNumber == surahNumber));
    }
    
    return allBookmarks;
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      await _bookmarkService.clearAllBookmarks();
      
      final clearedState = <BookmarkCategory, List<BookmarkModel>>{};
      for (final category in BookmarkCategory.values) {
        clearedState[category] = [];
      }
      
      state = clearedState;
    } catch (e) {
      throw Exception('Failed to clear bookmarks: $e');
    }
  }

  // Refresh bookmarks
  Future<void> refresh() async {
    await _loadBookmarks();
  }
}

// Provider for specific category bookmarks
final bookmarksForCategoryProvider = Provider.family<List<BookmarkModel>, BookmarkCategory>(
  (ref, category) {
    final bookmarksByCategory = ref.watch(bookmarksByCategoryProvider);
    return bookmarksByCategory[category] ?? [];
  },
);

// Provider for bookmark counts
final bookmarkCountProvider = Provider.family<int, BookmarkCategory?>(
  (ref, category) {
    final bookmarksByCategory = ref.watch(bookmarksByCategoryProvider);
    
    if (category == null) {
      // Return total count
      return bookmarksByCategory.values.fold(0, (sum, bookmarks) => sum + bookmarks.length);
    }
    
    return bookmarksByCategory[category]?.length ?? 0;
  },
);

// Provider for recent bookmarks
final recentBookmarksProvider = Provider<List<BookmarkModel>>(
  (ref) {
    final notifier = ref.read(bookmarksByCategoryProvider.notifier);
    return notifier.getRecentBookmarks();
  },
);

// Provider for bookmark search
final bookmarkSearchProvider = Provider.family<List<BookmarkModel>, String>(
  (ref, query) {
    final notifier = ref.read(bookmarksByCategoryProvider.notifier);
    return notifier.searchBookmarks(query);
  },
);

// Provider for bookmarks by surah
final bookmarksBySurahProvider = Provider.family<List<BookmarkModel>, int>(
  (ref, surahNumber) {
    final notifier = ref.read(bookmarksByCategoryProvider.notifier);
    return notifier.getBookmarksBySurah(surahNumber);
  },
);

// Supporting bookmark service provider
final bookmarkServiceProvider = Provider<BookmarkService>(
  (ref) => BookmarkService(),
);