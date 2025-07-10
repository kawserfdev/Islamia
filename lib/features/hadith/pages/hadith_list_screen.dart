import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/hadith/hadith_providers.dart';
import 'package:islamia/data/models/hadith/hadith_collection.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
import 'package:islamia/features/hadith/pages/hadith_categories_screen.dart';
import 'hadith_detail_screen.dart';

class HadithListScreen extends ConsumerStatefulWidget {
  final HadithCollection collection;

  const HadithListScreen({Key? key, required this.collection}) : super(key: key);

  @override
  ConsumerState<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends ConsumerState<HadithListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<HadithModel> _allHadiths = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreHadiths();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hadithsAsync = ref.watch(hadithsProvider(HadithParams(
      collectionId: widget.collection.id,
      page: _currentPage,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.collection.name),
            Text(
              'by ${widget.collection.author}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filter by Book'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Browse Categories'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: hadithsAsync.when(
        data: (hadiths) {
          if (_currentPage == 1) {
            _allHadiths = hadiths;
          }
          return _buildHadithList();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error.toString()),
      ),
    );
  }

  Widget _buildHadithList() {
    if (_allHadiths.isEmpty) {
      return const Center(
        child: Text('No hadiths found'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _allHadiths.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allHadiths.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final hadith = _allHadiths[index];
        return _buildHadithCard(hadith);
      },
    );
  }

  Widget _buildHadithCard(HadithModel hadith) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(hadith),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with hadith number and grade
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hadith ${hadith.hadithNumber}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hadith.grade.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: hadith.grade.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      hadith.grade.displayName.split(' ')[0], // Just the grade name
                      style: TextStyle(
                        color: hadith.grade.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Arabic text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  hadith.arabicText,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    fontFamily: 'Noto Naskh Arabic',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Translation
              if (hadith.translations.isNotEmpty)
                Text(
                  hadith.getTranslation('en'),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // Footer with narrator and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Narrator: ${hadith.narrator}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return FutureBuilder<bool>(
                        future: ref.read(hadithBookmarksProvider.notifier).isBookmarked(hadith.id),
                        builder: (context, snapshot) {
                          final isBookmarked = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () => _toggleBookmark(hadith, isBookmarked),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.grey),
                    onPressed: () => _shareHadith(hadith),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Failed to load hadiths', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(hadithsProvider(HadithParams(
              collectionId: widget.collection.id,
              page: _currentPage,
            ))),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _loadMoreHadiths() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final newHadiths = await ref.read(hadithsProvider(HadithParams(
        collectionId: widget.collection.id,
        page: _currentPage,
      )).future);

      setState(() {
        _allHadiths.addAll(newHadiths);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

  void _navigateToDetail(HadithModel hadith) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HadithDetailScreen(hadith: hadith),
      ),
    );
  }

  void _toggleBookmark(HadithModel hadith, bool isCurrentlyBookmarked) async {
    if (isCurrentlyBookmarked) {
      await ref.read(hadithBookmarksProvider.notifier).removeBookmark(hadith.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed')),
        );
      }
    } else {
      await ref.read(hadithBookmarksProvider.notifier).addBookmark(hadith);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark added')),
        );
      }
    }
    setState(() {}); // Refresh the UI
  }

  void _shareHadith(HadithModel hadith) async {
    final text = hadith.getShareText(
      languageCode: 'en',
      includeNarrator: true,
      includeReference: true,
    );
    
    // Use share plugin
    // await Share.share(text);
    
    // For now, show in dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Hadith'),
        content: SingleChildScrollView(
          child: SelectableText(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    // Implement search functionality
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'filter':
        _showBookFilter();
        break;
      case 'categories':
        _showCategories();
        break;
    }
  }

  void _showBookFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Filter by Book',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.collection.books.length,
                itemBuilder: (context, index) {
                  final book = widget.collection.books[index];
                  return ListTile(
                    title: Text(book.name),
                    subtitle: Text('${book.totalHadith} hadiths'),
                    onTap: () {
                      Navigator.pop(context);
                      _filterByBook(book);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HadithCategoriesScreen(),
      ),
    );
  }

  void _filterByBook(HadithBook book) {
    // Implement book filtering
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HadithListScreen(
          collection: widget.collection,
        ),
      ),
    );
  }
}