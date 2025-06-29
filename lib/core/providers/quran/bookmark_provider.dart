import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
import 'package:islamia/core/services/quran/bookmark_service.dart';
final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

final bookmarksProvider = StateNotifierProvider<BookmarkNotifier, AsyncValue<List<BookmarkModel>>>((ref) {
  return BookmarkNotifier(ref.read(bookmarkServiceProvider));
});

final bookmarkCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final bookmarkService = ref.read(bookmarkServiceProvider);
  return await bookmarkService.getCategories();
});

final bookmarksByCategory = FutureProvider.family<List<BookmarkModel>, String>((ref, category) async {
  final bookmarkService = ref.read(bookmarkServiceProvider);
  return await bookmarkService.getBookmarksByCategory(category);
});

class BookmarkNotifier extends StateNotifier<AsyncValue<List<BookmarkModel>>> {
  final BookmarkService _bookmarkService;

  BookmarkNotifier(this._bookmarkService) : super(const AsyncValue.loading()) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    try {
      final bookmarks = await _bookmarkService.getAllBookmarks();
      state = AsyncValue.data(bookmarks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      await _bookmarkService.addBookmark(bookmark);
      await loadBookmarks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeBookmark(String id) async {
    try {
      await _bookmarkService.removeBookmark(id);
      await loadBookmarks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    return await _bookmarkService.isBookmarked(surahNumber, ayahNumber);
  }

  Future<List<BookmarkModel>> searchBookmarks(String query) async {
    return await _bookmarkService.searchBookmarks(query);
  }

  Future<void> updateBookmark(BookmarkModel bookmark) async {
    try {
      await _bookmarkService.updateBookmark(bookmark);
      await loadBookmarks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}