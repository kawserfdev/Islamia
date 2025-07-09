import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/bookmark_provider.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
class BookmarksSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final Function(AyahModel) onAyahSelected;

  const BookmarksSheet({
    Key? key,
    required this.scrollController,
    required this.onAyahSelected,
  }) : super(key: key);

  @override
  ConsumerState<BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends ConsumerState<BookmarksSheet> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  
  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(bookmarksProvider);
    final settings = ref.watch(quranSettingsProvider);
    
    final filteredBookmarks = _filterBookmarks(bookmarks.bookmarks);

    return Container(
      decoration: BoxDecoration(
        color: settings.nightMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'My Bookmarks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: settings.nightMode ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filteredBookmarks.length} bookmarks',
                  style: TextStyle(
                    color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Search and filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search bookmarks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: settings.nightMode ? Colors.grey[800] : Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: settings.nightMode ? Colors.grey[800] : Colors.grey[100],
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(value: 'recent', child: Text('Recent')),
                          DropdownMenuItem(value: 'favorites', child: Text('Favorites')),
                          DropdownMenuItem(value: 'notes', child: Text('With Notes')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFilter = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showSortOptions(context),
                      icon: const Icon(Icons.sort),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bookmarks list
          Expanded(
            child: filteredBookmarks.isEmpty
                ? _buildEmptyState(settings)
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = filteredBookmarks[index];
                      return _buildBookmarkTile(bookmark, settings);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<BookmarkModel> _filterBookmarks(List<BookmarkModel> bookmarks) {
    var filtered = bookmarks;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((bookmark) {
        return bookmark.ayahText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               bookmark.surahName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (bookmark.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    // Apply category filter
    switch (_selectedFilter) {
      case 'recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filtered = filtered.take(20).toList();
        break;
      case 'favorites':
        // filtered = filtered.where((b) => b.isFavorite).toList();
        break;
      case 'notes':
        filtered = filtered.where((b) => b.note != null && b.note!.isNotEmpty).toList();
        break;
    }
    
    return filtered;
  }

  Widget _buildEmptyState(QuranSettings settings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: settings.nightMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon on any ayah to save it here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: settings.nightMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkTile(BookmarkModel bookmark, QuranSettings settings) {
    return Card(
      color: settings.nightMode ? Colors.grey[800] : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Create an Ayah object from bookmark data
          final ayah = AyahModel(
            number: bookmark.ayahNumber,
            text: bookmark.ayahText,
            surahNumber: bookmark.surahNumber,
            ayahNumber: bookmark.ayahNumber,
            juz: 1, // This would need to be stored in bookmark
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          );
          widget.onAyahSelected(ayah);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Surah and Ayah info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${bookmark.surahNumber}:${bookmark.ayahNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bookmark.surahName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: settings.nightMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleBookmarkAction(value, bookmark),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit Note'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 16),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Arabic text
              Text(
                bookmark.ayahText,
                style: TextStyle(
                  fontFamily: 'Noto Naskh Arabic',
                  fontSize: 16,
                  height: 1.8,
                  color: settings.nightMode ? Colors.white : Colors.black,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Note if available
              if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: settings.nightMode ? Colors.grey[700] : Colors.amber[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: settings.nightMode ? Colors.grey[600]! : Colors.amber[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: settings.nightMode ? Colors.amber[300] : Colors.amber[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bookmark.note!,
                          style: TextStyle(
                            fontSize: 13,
                            color: settings.nightMode ? Colors.amber[200] : Colors.amber[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Timestamp and tags
              Row(
                children: [
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (bookmark.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: bookmark.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: settings.nightMode ? Colors.grey[700] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort Bookmarks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Date Added (Newest)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled),
              title: const Text('Date Added (Oldest)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Surah Order'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('Ayah Number'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBookmarkAction(String action, BookmarkModel bookmark) {
    final bookmarkNotifier = ref.read(bookmarksProvider.notifier);
    
    switch (action) {
      case 'edit':
        _showEditNoteDialog(bookmark);
        break;
      case 'share':
        _shareBookmark(bookmark);
        break;
      case 'delete':
        bookmarkNotifier.removeBookmark(bookmark.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark deleted')),
        );
        break;
    }
  }

  void _showEditNoteDialog(BookmarkModel bookmark) {
    final TextEditingController controller = TextEditingController(text: bookmark.note);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final bookmarkNotifier = ref.read(bookmarksProvider.notifier);
              bookmarkNotifier.updateBookmarkNote(bookmark.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _shareBookmark(BookmarkModel bookmark) {
    final text = '''
${bookmark.ayahText}

${bookmark.surahName} - ${bookmark.surahNumber}:${bookmark.ayahNumber}

${bookmark.note ?? ''}

From Islamia App
''';
    // Share.share(text);
    print('Sharing bookmark: $text');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}