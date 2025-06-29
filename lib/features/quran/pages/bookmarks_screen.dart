// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:islamia/core/providers/quran/bookmark_provider.dart';
// import 'package:islamia/core/providers/quran/settings_provider.dart';
// import 'package:islamia/data/models/quran/bookmark_model.dart';
// import 'package:islamia/features/quran/widgets/bookmark_tile.dart';
// import 'package:share_plus/share_plus.dart';

// class BookmarksScreen extends ConsumerStatefulWidget {
//   const BookmarksScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
// }

// class _BookmarksScreenState extends ConsumerState<BookmarksScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String _selectedCategory = 'All';
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settings = ref.watch(quranSettingsProvider);
//     final bookmarksAsync = ref.watch(bookmarksProvider);
//     final categoriesAsync = ref.watch(bookmarkCategoriesProvider);

//     return Scaffold(
//       backgroundColor: settings.nightMode ? Colors.black : Colors.white,
//       appBar: AppBar(
//         title: const Text('Bookmarks'),
//         backgroundColor: settings.nightMode ? Colors.grey[900] : Colors.green[700],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () => _showBookmarkOptions(),
//             icon: const Icon(Icons.more_vert),
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(text: 'All Bookmarks'),
//             Tab(text: 'Categories'),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: settings.nightMode ? Colors.grey[900] : Colors.green[700],
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Search bookmarks...',
//                 hintStyle: const TextStyle(color: Colors.white70),
//                 prefixIcon: const Icon(Icons.search, color: Colors.white70),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() {
//                             _searchQuery = '';
//                           });
//                         },
//                         icon: const Icon(Icons.clear, color: Colors.white70),
//                       )
//                     : null,
//                 filled: true,
//                 fillColor: Colors.white.withOpacity(0.1),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding:  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//             ),
//           ),

//           // Content
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // All Bookmarks Tab
//                 bookmarksAsync.when(
//                   data: (bookmarks) => _buildBookmarksList(bookmarks, settings),
//                   loading: () => const Center(child: CircularProgressIndicator()),
//                   error: (error, stack) => _buildErrorWidget(error, settings),
//                 ),

//                 // Categories Tab
//                 categoriesAsync.when(
//                   data: (categories) => _buildCategoriesView(categories, settings),
//                   loading: () => const Center(child: CircularProgressIndicator()),
//                   error: (error, stack) => _buildErrorWidget(error, settings),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddBookmarkDialog(),
//         backgroundColor: Colors.green[700],
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildBookmarksList(List<BookmarkModel> allBookmarks, QuranSettings settings) {
//     List<BookmarkModel> filteredBookmarks = allBookmarks;

//     // Filter by search query
//     if (_searchQuery.isNotEmpty) {
//       final notifier = ref.read(bookmarksProvider.notifier);
//       return FutureBuilder<List<BookmarkModel>>(
//         future: notifier.searchBookmarks(_searchQuery),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return _buildErrorWidget(snapshot.error, settings);
//           }
//           return _buildBookmarksListView(snapshot.data ?? [], settings);
//         },
//       );
//     }

//     // Filter by category
//     if (_selectedCategory != 'All') {
//       filteredBookmarks = allBookmarks
//           .where((bookmark) => bookmark.category == _selectedCategory)
//           .toList();
//     }

//     return _buildBookmarksListView(filteredBookmarks, settings);
//   }

//   Widget _buildBookmarksListView(List<BookmarkModel> bookmarks, QuranSettings settings) {
//     if (bookmarks.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.bookmark_border,
//               size: 64,
//               color: settings.nightMode ? Colors.grey[600] : Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _searchQuery.isNotEmpty ? 'No bookmarks found' : 'No bookmarks yet',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: settings.nightMode ? Colors.white : Colors.black,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _searchQuery.isNotEmpty
//                   ? 'Try different search terms'
//                   : 'Bookmark your favorite verses while reading',
//               style: TextStyle(
//                 color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     return AnimationLimiter(
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: bookmarks.length,
//         itemBuilder: (context, index) {
//           final bookmark = bookmarks[index];
//           return AnimationConfiguration.staggeredList(
//             position: index,
//             duration: const Duration(milliseconds: 375),
//             child: SlideAnimation(
//               verticalOffset: 50.0,
//               child: FadeInAnimation(
//                 child: BookmarkTile(
//                   bookmark: bookmark,
//                   settings: settings,
//                   onTap: () => _navigateToBookmark(bookmark),
//                   onEdit: () => _editBookmark(bookmark),
//                   onDelete: () => _deleteBookmark(bookmark),
//                   onShare: () => _shareBookmark(bookmark),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCategoriesView(List<String> categories, QuranSettings settings) {
//     final allCategories = ['All', ...categories];

//     return Column(
//       children: [
//         // Category Filter
//         Container(
//           height: 60,
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: allCategories.length,
//             itemBuilder: (context, index) {
//               final category = allCategories[index];
//               final isSelected = category == _selectedCategory;
              
//               return Container(
//                 margin: const EdgeInsets.only(right: 8),
//                 child: FilterChip(
//                   label: Text(category),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     setState(() {
//                       _selectedCategory = category;
//                     });
//                   },
//                   selectedColor: Colors.green[100],
//                   checkmarkColor: Colors.green[700],
//                 ),
//               );
//             },
//           ),
//         ),

//         // Bookmarks by Category
//         Expanded(
//           child: _selectedCategory == 'All'
//               ? const Center(child: Text('Select a category to view bookmarks'))
//               : Consumer(
//                   builder: (context, ref, child) {
//                     final bookmarksByCategory = ref.watch(bookmarksByCategoryProvider(_selectedCategory));
//                     return bookmarksByCategory.when(
//                       data: (bookmarks) => _buildBookmarksListView(bookmarks, settings),
//                       loading: () => const Center(child: CircularProgressIndicator()),
//                       error: (error, stack) => _buildErrorWidget(error, settings),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorWidget(dynamic error, QuranSettings settings) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64,
//             color: settings.nightMode ? Colors.red[300] : Colors.red,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Error loading bookmarks',
//             style: TextStyle(
//               fontSize: 18,
//               color: settings.nightMode ? Colors.white : Colors.black,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             error.toString(),
//             style: TextStyle(
//               color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () => ref.read(bookmarksProvider.notifier).loadBookmarks(),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showBookmarkOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.share),
//             title: const Text('Export Bookmarks'),
//             onTap: () {
//               Navigator.pop(context);
//               _exportBookmarks();
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete_sweep),
//             title: const Text('Clear All Bookmarks'),
//             onTap: () {
//               Navigator.pop(context);
//               _showClearAllDialog();
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.category),
//             title: const Text('Manage Categories'),
//             onTap: () {
//               Navigator.pop(context);
//               _showManageCategoriesDialog();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddBookmarkDialog() {
//     // This would typically be called from the reader screen
//     // For demo purposes, showing a placeholder dialog
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add Bookmark'),
//         content: const Text('Bookmarks are added while reading verses in the Quran reader.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToBookmark(BookmarkModel bookmark) {
//     // Navigate to the specific ayah in the reader
//     Navigator.pop(context, bookmark);
//   }

//   void _editBookmark(BookmarkModel bookmark) {
//     showDialog(
//       context: context,
//       builder: (context) => EditBookmarkDialog(bookmark: bookmark),
//     );
//   }

//   void _deleteBookmark(BookmarkModel bookmark) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Bookmark'),
//         content: Text('Are you sure you want to delete this bookmark from ${bookmark.surahName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ref.read(bookmarksProvider.notifier).removeBookmark(bookmark.id);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Bookmark deleted')),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _shareBookmark(BookmarkModel bookmark) {
//     final text = '${bookmark.ayahText}\n\n- ${bookmark.displayText}\n\nShared from Islamia App';
//     Share.share(text);
//   }

//   void _exportBookmarks() async {
//     final bookmarksAsync = ref.read(bookmarksProvider);
//     bookmarksAsync.when(
//       data: (bookmarks) {
//         if (bookmarks.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No bookmarks to export')),
//           );
//           return;
//         }

//         final exportText = bookmarks.map((bookmark) {
//           return '${bookmark.displayText}\n${bookmark.ayahText}\n${bookmark.note ?? ''}\n---';
//         }).join('\n\n');

//         Share.share(exportText, subject: 'My Quran Bookmarks');
//       },
//       loading: () {},
//       error: (error, stack) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to export bookmarks')),
//         );
//       },
//     );
//   }

//   void _showClearAllDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear All Bookmarks'),
//         content: const Text('Are you sure you want to delete all bookmarks? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // Clear all bookmarks (implementation depends on your service)
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('All bookmarks cleared')),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Clear All'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showManageCategoriesDialog() {
//     // Implementation for managing bookmark categories
//     showDialog(
//       context: context,
//       builder: (context) => const ManageCategoriesDialog(),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/bookmarks_by_category_provider.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';

class QuranBookmarksScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksByCategory = ref.watch(bookmarksByCategoryProvider);
    final generalBookmarks = ref.watch(bookmarksForCategoryProvider(BookmarkCategory.general));
    
    return Scaffold(
      appBar: AppBar(title: Text('Quran Bookmarks')),
      body: Column(
        children: [
          // Show bookmark count
          Text('General Bookmarks: ${generalBookmarks.length}'),
          
          // Add bookmark button
          ElevatedButton(
            onPressed: () async {
              final bookmark = BookmarkModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                surahNumber: 1,
                ayahNumber: 1,
                surahName: 'Al-Fatihah',
                ayahText: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                category: 'General',
                createdAt: DateTime.now(),
                tags: ['opening', 'prayer'],
              );
              
              await ref.read(bookmarksByCategoryProvider.notifier)
                  .addBookmark(bookmark);
            },
            child: Text('Add Bookmark'),
          ),
          
          // Display bookmarks
          Expanded(
            child: ListView.builder(
              itemCount: generalBookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = generalBookmarks[index];
                return Card(
                  child: ListTile(
                    title: Text('${bookmark.surahName} ${bookmark.ayahNumber}:${bookmark.surahNumber}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.ayahText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (bookmark.note != null)
                          Text(
                            'Note: ${bookmark.note}',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        if (bookmark.tags.isNotEmpty)
                          Wrap(
                            children: bookmark.tags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await ref.read(bookmarksByCategoryProvider.notifier)
                            .removeBookmark(bookmark.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),]
      ),
        
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookmarkDialog(context, ref),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddBookmarkDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        onBookmarkAdded: (bookmark) async {
          await ref.read(bookmarksByCategoryProvider.notifier)
              .addBookmark(bookmark);
        },
      ),
    );
  }
}

// Add bookmark dialog widget
class AddBookmarkDialog extends StatefulWidget {
  final Function(BookmarkModel) onBookmarkAdded;

  const AddBookmarkDialog({Key? key, required this.onBookmarkAdded}) : super(key: key);

  @override
  _AddBookmarkDialogState createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _surahController = TextEditingController();
  final _ayahController = TextEditingController();
  final _surahNameController = TextEditingController();
  final _ayahTextController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  String _selectedCategory = 'General';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Bookmark'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _surahController,
                decoration: InputDecoration(labelText: 'Surah Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter surah number';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1 || number > 114) {
                    return 'Please enter valid surah number (1-114)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ayahController,
                decoration: InputDecoration(labelText: 'Ayah Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ayah number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _surahNameController,
                decoration: InputDecoration(labelText: 'Surah Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter surah name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ayahTextController,
                decoration: InputDecoration(labelText: 'Ayah Text'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ayah text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Note (Optional)'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'prayer, guidance, patience',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: BookmarkCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category.displayName,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final tags = _tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();

              final bookmark = BookmarkModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                surahNumber: int.parse(_surahController.text),
                ayahNumber: int.parse(_ayahController.text),
                surahName: _surahNameController.text,
                ayahText: _ayahTextController.text,
                note: _noteController.text.isEmpty ? null : _noteController.text,
                category: _selectedCategory,
                createdAt: DateTime.now(),
                tags: tags,
              );

              widget.onBookmarkAdded(bookmark);
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _surahController.dispose();
    _ayahController.dispose();
    _surahNameController.dispose();
    _ayahTextController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}