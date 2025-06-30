// import 'dart:convert';
// import 'package:islamia/data/models/quran/bookmark_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BookmarkService {
//   static const String _bookmarksKey = 'bookmarks';
  
//   // Get all bookmarks
//   Future<List<BookmarkModel>> getAllBookmarks() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      
//       return bookmarksJson
//           .map((json) => BookmarkModel.fromJson(jsonDecode(json)))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load bookmarks: $e');
//     }
//   }

//   // Add a new bookmark
//   Future<BookmarkModel> addBookmark(BookmarkModel bookmark) async {
//     try {
//       final bookmarks = await getAllBookmarks();
//       bookmarks.add(bookmark);
//       await _saveBookmarks(bookmarks);
//       return bookmark;
//     } catch (e) {
//       throw Exception('Failed to add bookmark: $e');
//     }
//   }

//   // Update a bookmark
//   Future<BookmarkModel> updateBookmark(BookmarkModel bookmark) async {
//     try {
//       final bookmarks = await getAllBookmarks();
//       final index = bookmarks.indexWhere((b) => b.id == bookmark.id);
      
//       if (index == -1) {
//         throw Exception('Bookmark not found');
//       }
      
//       bookmarks[index] = bookmark;
//       await _saveBookmarks(bookmarks);
//       return bookmark;
//     } catch (e) {
//       throw Exception('Failed to update bookmark: $e');
//     }
//   }

//   // Remove a bookmark
//   Future<void> removeBookmark(String bookmarkId) async {
//     try {
//       final bookmarks = await getAllBookmarks();
//       bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
//       await _saveBookmarks(bookmarks);
//     } catch (e) {
//       throw Exception('Failed to remove bookmark: $e');
//     }
//   }

//   // Clear all bookmarks
//   Future<void> clearAllBookmarks() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_bookmarksKey);
//     } catch (e) {
//       throw Exception('Failed to clear bookmarks: $e');
//     }
//   }

//   // Private helper method to save bookmarks
//   Future<void> _saveBookmarks(List<BookmarkModel> bookmarks) async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookmarksJson = bookmarks
//         .map((bookmark) => jsonEncode(bookmark.toJson()))
//         .toList();
    
//     await prefs.setStringList(_bookmarksKey, bookmarksJson);
//   }
// }

import 'dart:convert';
import 'package:islamia/core/providers/quran/bookmark_notifier.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarks';
  static const String _bookmarkCounterKey = 'bookmark_counter';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  
  
  // Get all bookmarks
  Future<List<BookmarkModel>> getAllBookmarks() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      
      final bookmarks = bookmarksJson
          .map((json) => BookmarkModel.fromJson(jsonDecode(json)))
          .toList();
      
      // Sort by creation date (newest first)
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return bookmarks;
    } catch (e) {
      throw Exception('Failed to load bookmarks: $e');
    }
  }

  // Add a new bookmark
  Future<BookmarkModel> addBookmark(BookmarkModel bookmark) async {
    try {
      final bookmarks = await getAllBookmarks();
      
      // Check if bookmark already exists
      final existingIndex = bookmarks.indexWhere(
        (b) => b.surahNumber == bookmark.surahNumber && 
               b.ayahNumber == bookmark.ayahNumber
      );
      
      if (existingIndex != -1) {
        throw Exception('Bookmark already exists for this ayah');
      }
      
      // Generate unique ID if not provided
      final newBookmark = bookmark.id.isEmpty 
          ? bookmark.copyWith(
              id: await _generateBookmarkId(),
              createdAt: DateTime.now(),
            )
          : bookmark;
      
      bookmarks.add(newBookmark);
      await _saveBookmarks(bookmarks);
      return newBookmark;
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  // Update a bookmark
  Future<BookmarkModel> updateBookmark(BookmarkModel bookmark) async {
    try {
      final bookmarks = await getAllBookmarks();
      final index = bookmarks.indexWhere((b) => b.id == bookmark.id);
      
      if (index == -1) {
        throw Exception('Bookmark not found');
      }
      
      bookmarks[index] = bookmark;
      await _saveBookmarks(bookmarks);
      return bookmark;
    } catch (e) {
      throw Exception('Failed to update bookmark: $e');
    }
  }

  // Remove a bookmark
  Future<void> removeBookmark(String bookmarkId) async {
    try {
      final bookmarks = await getAllBookmarks();
      final removed = bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
      
      // if (removed == 0) {
      //   throw Exception('Bookmark not found');
      // }
      
      await _saveBookmarks(bookmarks);
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  // Remove bookmark by surah and ayah
  Future<void> removeBookmarkByAyah(int surahNumber, int ayahNumber) async {
    try {
      final bookmarks = await getAllBookmarks();
      final removed = bookmarks.removeWhere(
        (bookmark) => bookmark.surahNumber == surahNumber && 
                     bookmark.ayahNumber == ayahNumber
      );
      
      // if (removed == 0) {
      //   throw Exception('No bookmark found for this ayah');
      // }
      
      await _saveBookmarks(bookmarks);
    } catch (e) {
      throw Exception('Failed to remove bookmark by ayah: $e');
    }
  }

  // Check if bookmark exists
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    try {
      final bookmarks = await getAllBookmarks();
      return bookmarks.any(
        (bookmark) => bookmark.surahNumber == surahNumber && 
                     bookmark.ayahNumber == ayahNumber
      );
    } catch (e) {
      return false;
    }
  }

  // Get all unique categories
  Future<List<String>> getAllCategories() async {
    try {
      final bookmarks = await getAllBookmarks();
      final categories = bookmarks
          .map((bookmark) => bookmark.category)
          .toSet()
          .toList();
      
      // Add default categories if none exist
      if (categories.isEmpty) {
        categories.addAll([
          'General',
          'Favorites',
          'To Read',
          'Important',
          'Memorization',
          'Reflection',
        ]);
      }
      
      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Failed to get all categories: $e');
    }
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    try {
      final bookmarks = await getAllBookmarks();
      final tags = <String>{};
      
      for (final bookmark in bookmarks) {
        tags.addAll(bookmark.tags);
      }
      
      final sortedTags = tags.toList();
      sortedTags.sort();
      return sortedTags;
    } catch (e) {
      throw Exception('Failed to get all tags: $e');
    }
  }

  // Export bookmarks to JSON
  Future<String> exportBookmarks() async {
    try {
      final bookmarks = await getAllBookmarks();
      final exportData = {
        'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
        'exported_at': DateTime.now().toIso8601String(),
        'version': '1.0',
        'app': 'Islamia',
        'total_count': bookmarks.length,
      };
      return jsonEncode(exportData);
    } catch (e) {
      throw Exception('Failed to export bookmarks: $e');
    }
  }

  // Import bookmarks from JSON
  Future<ImportResult> importBookmarks(String jsonData, {bool overwrite = false}) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final importedBookmarksData = data['bookmarks'] as List;
      
      final importedBookmarks = importedBookmarksData
          .map((json) => BookmarkModel.fromJson(json))
          .toList();
      
      if (overwrite) {
        await _saveBookmarks(importedBookmarks);
        return ImportResult(
          success: true,
          imported: importedBookmarks.length,
          skipped: 0,
          message: 'Successfully imported ${importedBookmarks.length} bookmarks',
        );
      } else {
        final existingBookmarks = await getAllBookmarks();
        int imported = 0;
        int skipped = 0;
        
        for (final bookmark in importedBookmarks) {
          final exists = existingBookmarks.any(
            (b) => b.surahNumber == bookmark.surahNumber && 
                   b.ayahNumber == bookmark.ayahNumber
          );
          
          if (!exists) {
            existingBookmarks.add(bookmark.copyWith(
              id: await _generateBookmarkId(),
              createdAt: DateTime.now(),
            ));
            imported++;
          } else {
            skipped++;
          }
        }
        
        await _saveBookmarks(existingBookmarks);
        return ImportResult(
          success: true,
          imported: imported,
          skipped: skipped,
          message: 'Imported $imported bookmarks, skipped $skipped duplicates',
        );
      }
    } catch (e) {
      return ImportResult(
        success: false,
        imported: 0,
        skipped: 0,
        message: 'Failed to import bookmarks: $e',
      );
    }
  }

  // Get bookmark statistics
  Future<BookmarkServiceStats> getBookmarkStats() async {
    try {
      final bookmarks = await getAllBookmarks();
      final categories = <String, int>{};
      final surahs = <int>{};
      final tagsCount = <String, int>{};
      
      for (final bookmark in bookmarks) {
        // Count categories
        categories[bookmark.category] = (categories[bookmark.category] ?? 0) + 1;
        
        // Count unique surahs
        surahs.add(bookmark.surahNumber);
        
        // Count tags
        for (final tag in bookmark.tags) {
          tagsCount[tag] = (tagsCount[tag] ?? 0) + 1;
        }
      }
      
      // Find oldest and newest bookmarks
      BookmarkModel? oldestBookmark;
      BookmarkModel? newestBookmark;
      
      if (bookmarks.isNotEmpty) {
        oldestBookmark = bookmarks.reduce(
          (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b
        );
        newestBookmark = bookmarks.reduce(
          (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b
        );
      }
      
      return BookmarkServiceStats(
        totalBookmarks: bookmarks.length,
        categoriesCount: categories.length,
        surahsWithBookmarks: surahs.length,
        categoryDistribution: categories,
        tagDistribution: tagsCount,
        oldestBookmark: oldestBookmark,
        newestBookmark: newestBookmark,
        averageBookmarksPerSurah: surahs.isNotEmpty ? bookmarks.length / surahs.length : 0.0,
      );
    } catch (e) {
      throw Exception('Failed to get bookmark stats: $e');
    }
  }

  // Get bookmarks by category
  Future<List<BookmarkModel>> getBookmarksByCategory(String category) async {
    try {
      final bookmarks = await getAllBookmarks();
      return bookmarks.where((bookmark) => bookmark.category == category).toList();
    } catch (e) {
      throw Exception('Failed to get bookmarks by category: $e');
    }
  }

  // Get bookmarks by surah
  Future<List<BookmarkModel>> getBookmarksBySurah(int surahNumber) async {
    try {
      final bookmarks = await getAllBookmarks();
      final surahBookmarks = bookmarks
          .where((bookmark) => bookmark.surahNumber == surahNumber)
          .toList();
      
      // Sort by ayah number
      surahBookmarks.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
      
      return surahBookmarks;
    } catch (e) {
      throw Exception('Failed to get bookmarks by surah: $e');
    }
  }

  // Search bookmarks
  Future<List<BookmarkModel>> searchBookmarks(String query) async {
    try {
      final bookmarks = await getAllBookmarks();
      final lowercaseQuery = query.toLowerCase();
      
      return bookmarks.where((bookmark) {
        return bookmark.surahName.toLowerCase().contains(lowercaseQuery) ||
               bookmark.ayahText.toLowerCase().contains(lowercaseQuery) ||
               bookmark.note?.toLowerCase().contains(lowercaseQuery) == true ||
               bookmark.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search bookmarks: $e');
    }
  }

  // Get recent bookmarks
  Future<List<BookmarkModel>> getRecentBookmarks({int limit = 10}) async {
    try {
      final bookmarks = await getAllBookmarks();
      return bookmarks.take(limit).toList(); // Already sorted by date
    } catch (e) {
      throw Exception('Failed to get recent bookmarks: $e');
    }
  }

  // Toggle bookmark (add if doesn't exist, remove if exists)
  Future<bool> toggleBookmark(BookmarkModel bookmark) async {
    try {
      final isBookmarked = await this.isBookmarked(
        bookmark.surahNumber, 
        bookmark.ayahNumber
      );
      
      if (isBookmarked) {
        await removeBookmarkByAyah(bookmark.surahNumber, bookmark.ayahNumber);
        return false; // Removed
      } else {
        await addBookmark(bookmark);
        return true; // Added
      }
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
      await prefs.remove(_bookmarkCounterKey);
    } catch (e) {
      throw Exception('Failed to clear bookmarks: $e');
    }
  }

  // Private helper method to save bookmarks
  Future<void> _saveBookmarks(List<BookmarkModel> bookmarks) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final bookmarksJson = bookmarks
          .map((bookmark) => jsonEncode(bookmark.toJson()))
          .toList();
      
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
    } catch (e) {
      throw Exception('Failed to save bookmarks: $e');
    }
  }

  // Generate unique bookmark ID
  Future<String> _generateBookmarkId() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      int counter = prefs.getInt(_bookmarkCounterKey) ?? 0;
      counter++;
      await prefs.setInt(_bookmarkCounterKey, counter);
      return 'bookmark_${DateTime.now().millisecondsSinceEpoch}_$counter';
    } catch (e) {
      return 'bookmark_${DateTime.now().millisecondsSinceEpoch}';
    }
  }




  
}



// class AyahReference {
//   final int surahNumber;
//   final int ayahNumber;
//   const AyahReference({required this.surahNumber, required this.ayahNumber});

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is AyahReference &&
//           runtimeType == other.runtimeType &&
//           surahNumber == other.surahNumber &&
//           ayahNumber == other.ayahNumber;

//   @override
//   int get hashCode => Object.hash(surahNumber, ayahNumber);
// }



// Supporting classes for enhanced functionality
// class BookmarkServiceStats {
//   final int totalBookmarks;
//   final int categoriesCount;
//   final int surahsWithBookmarks;
//   final Map<String, int> categoryDistribution;
//   final Map<String, int> tagDistribution;
//   final BookmarkModel? oldestBookmark;
//   final BookmarkModel? newestBookmark;
//   final double averageBookmarksPerSurah;

//   BookmarkServiceStats({
//     required this.totalBookmarks,
//     required this.categoriesCount,
//     required this.surahsWithBookmarks,
//     required this.categoryDistribution,
//     required this.tagDistribution,
//     this.oldestBookmark,
//     this.newestBookmark,
//     required this.averageBookmarksPerSurah,
//   });

//   Duration? get bookmarkingDuration {
//     if (oldestBookmark == null || newestBookmark == null) return null;
//     return newestBookmark!.createdAt.difference(oldestBookmark!.createdAt);
//   }

//   String get mostUsedCategory {
//     if (categoryDistribution.isEmpty) return 'None';
//     return categoryDistribution.entries
//         .reduce((a, b) => a.value > b.value ? a : b)
//         .key;
//   }

//   String get mostUsedTag {
//     if (tagDistribution.isEmpty) return 'None';
//     return tagDistribution.entries
//         .reduce((a, b) => a.value > b.value ? a : b)
//         .key;
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'totalBookmarks': totalBookmarks,
//       'categoriesCount': categoriesCount,
//       'surahsWithBookmarks': surahsWithBookmarks,
//       'categoryDistribution': categoryDistribution,
//       'tagDistribution': tagDistribution,
//       'averageBookmarksPerSurah': averageBookmarksPerSurah,
//       'oldestBookmark': oldestBookmark?.toJson(),
//       'newestBookmark': newestBookmark?.toJson(),
//     };
//   }

//   factory BookmarkServiceStats.fromJson(Map<String, dynamic> json) {
//     return BookmarkServiceStats(
//       totalBookmarks: json['totalBookmarks'] ?? 0,
//       categoriesCount: json['categoriesCount'] ?? 0,
//       surahsWithBookmarks: json['surahsWithBookmarks'] ?? 0,
//       categoryDistribution: Map<String, int>.from(json['categoryDistribution'] ?? {}),
//       tagDistribution: Map<String, int>.from(json['tagDistribution'] ?? {}),
//       averageBookmarksPerSurah: (json['averageBookmarksPerSurah'] ?? 0.0).toDouble(),
//       oldestBookmark: json['oldestBookmark'] != null 
//           ? BookmarkModel.fromJson(json['oldestBookmark'])
//           : null,
//       newestBookmark: json['newestBookmark'] != null 
//           ? BookmarkModel.fromJson(json['newestBookmark'])
//           : null,
//     );
//   }
// }

class ImportResult {
  final bool success;
  final int imported;
  final int skipped;
  final String message;

  ImportResult({
    required this.success,
    required this.imported,
    required this.skipped,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'imported': imported,
      'skipped': skipped,
      'message': message,
    };
  }

  factory ImportResult.fromJson(Map<String, dynamic> json) {
    return ImportResult(
      success: json['success'] ?? false,
      imported: json['imported'] ?? 0,
      skipped: json['skipped'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}