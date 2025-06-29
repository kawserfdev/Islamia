import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/bookmarks_by_category_provider.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
import 'package:islamia/features/quran/widgets/bookmark_tile.dart';

class BookmarkCategoriesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksByCategory = ref.watch(bookmarksByCategoryProvider);
    final totalCount = ref.watch(bookmarkCountProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks ($totalCount)'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Recent bookmarks section
          Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text('Recent Bookmarks'),
              trailing: Consumer(
                builder: (context, ref, child) {
                  final recentBookmarks = ref.watch(recentBookmarksProvider);
                  return Text('${recentBookmarks.length}');
                },
              ),
              onTap: () => _showRecentBookmarks(context, ref),
            ),
          ),
          
          // Category sections
          ...BookmarkCategory.values.map((category) {
            final count = ref.watch(bookmarkCountProvider(category));
            return Card(
              child: ExpansionTile(
                leading: _getCategoryIcon(category),
                title: Text(category.displayName),
                subtitle: Text('$count bookmarks'),
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final bookmarks = ref.watch(bookmarksForCategoryProvider(category));
                      return Column(
                        children: bookmarks.take(3).map((bookmark) {
                          return ListTile(
                            dense: true,
                            title: Text('${bookmark.surahName} ${bookmark.displayText}'),
                            subtitle: Text(
                              bookmark.ayahText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _showBookmarkDetails(context, bookmark),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  if (count > 3)
                    TextButton(
                      onPressed: () => _showCategoryBookmarks(context, ref, category),
                      child: Text('View all $count bookmarks'),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(BookmarkCategory category) {
    switch (category) {
      case BookmarkCategory.general:
        return Icon(Icons.bookmark);
      case BookmarkCategory.favorites:
        return Icon(Icons.favorite);
      case BookmarkCategory.toRead:
        return Icon(Icons.schedule);
      case BookmarkCategory.important:
        return Icon(Icons.priority_high);
      case BookmarkCategory.memorization:
        return Icon(Icons.psychology);
      case BookmarkCategory.reflection:
        return Icon(Icons.lightbulb);
    }
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    // showDialog(
    //   context: context,
    //   builder: (context) => BookmarkSearchDialog(),
    // );
  }

  void _showRecentBookmarks(BuildContext context, WidgetRef ref) {
    final recentBookmarks = ref.read(recentBookmarksProvider);
    _showBookmarksList(context, recentBookmarks, 'Recent Bookmarks');
  }

  void _showCategoryBookmarks(BuildContext context, WidgetRef ref, BookmarkCategory category) {
    final bookmarks = ref.read(bookmarksForCategoryProvider(category));
    _showBookmarksList(context, bookmarks, category.displayName);
  }

  void _showBookmarksList(BuildContext context, List<BookmarkModel> bookmarks, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookmarksListScreen(
          bookmarks: bookmarks,
          title: title,
        ),
      ),
    );
  }

  void _showBookmarkDetails(BuildContext context, BookmarkModel bookmark) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => BookmarkDetailsScreen(bookmark: bookmark),
    //   ),
    // );
  }
}

// Bookmarks list screen
class BookmarksListScreen extends ConsumerWidget {
  final List<BookmarkModel> bookmarks;
  final String title;

  const BookmarksListScreen({
    Key? key,
    required this.bookmarks,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text('${bookmark.surahName} ${bookmark.displayText}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.ayahText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category, size: 16),
                      SizedBox(width: 4),
                      Text(
                        bookmark.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Spacer(),
                      Text(
                        _formatDate(bookmark.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (bookmark.tags.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        children: bookmark.tags.take(3).map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: TextStyle(fontSize: 10),
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'move',
                    child: Row(
                      children: [
                        Icon(Icons.move_to_inbox),
                        SizedBox(width: 8),
                        Text('Move'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      _editBookmark(context, ref, bookmark);
                      break;
                    case 'move':
                      _moveBookmark(context, ref, bookmark);
                      break;
                    case 'delete':
                      _deleteBookmark(context, ref, bookmark);
                      break;
                  }
                },
              ),
              onTap: () => _showBookmarkDetails(context, bookmark),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editBookmark(BuildContext context, WidgetRef ref, BookmarkModel bookmark) {
    // Implementation for editing bookmark
    showDialog(
      context: context,
      builder: (context) => EditBookmarkDialog(
        bookmark: bookmark,
        
        // onBookmarkUpdated: (updatedBookmark) async {
        //   await ref.read(bookmarksByCategoryProvider.notifier)
        //       .updateBookmark(updatedBookmark);
        // },
      ),
    );
  }

  void _moveBookmark(BuildContext context, WidgetRef ref, BookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BookmarkCategory.values.map((category) {
            return ListTile(
              title: Text(category.displayName),
              onTap: () async {
                await ref.read(bookmarksByCategoryProvider.notifier)
                    .moveBookmarkToCategory(bookmark.id, category);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bookmark moved to ${category.displayName}')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _deleteBookmark(BuildContext context, WidgetRef ref, BookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Bookmark'),
        content: Text('Are you sure you want to delete this bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(bookmarksByCategoryProvider.notifier)
                  .removeBookmark(bookmark.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bookmark deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBookmarkDetails(BuildContext context, BookmarkModel bookmark) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => BookmarkDetailsScreen(bookmark: bookmark),
    //   ),
    // );
  }
}