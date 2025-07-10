import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/hadith/hadith_providers.dart';
import 'package:islamia/data/models/hadith/hadith_collection.dart';
import 'package:islamia/features/hadith/pages/hadith_bookmarks_screen.dart';
import 'package:islamia/features/hadith/pages/hadith_list_screen.dart';
import 'package:islamia/features/hadith/pages/hadith_search_screen.dart';
import 'package:islamia/features/hadith/widgets/daily_hadith_dialog.dart';

class HadithCollectionsScreen extends ConsumerWidget {
  const HadithCollectionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(hadithCollectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Collections'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showBookmarksScreen(context),
          ),
        ],
      ),
      body: collectionsAsync.when(
        data: (collections) => _buildCollectionGrid(context, collections),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error.toString(), ref),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDailyHadith(context, ref),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.today),
      ),
    );
  }

  Widget _buildCollectionGrid(BuildContext context, List<HadithCollection> collections) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return _buildCollectionCard(context, collection);
        },
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, HadithCollection collection) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToCollection(context, collection),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green[400]!,
                      Colors.green[600]!,
                    ],
                  ),
                ),
                child: collection.coverImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          collection.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildDefaultCover(collection),
                        ),
                      )
                    : _buildDefaultCover(collection),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.author,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.book, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${collection.totalHadith} Hadiths',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCover(HadithCollection collection) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[400]!, Colors.green[600]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 48,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 8),
          Text(
            collection.arabicName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load collections',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(hadithCollectionsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToCollection(BuildContext context, HadithCollection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HadithListScreen(collection: collection),
      ),
    );
  }

  void _showSearchScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HadithSearchScreen(),
      ),
    );
  }

  void _showBookmarksScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HadithBookmarksScreen(),
      ),
    );
  }

  void _showDailyHadith(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const DailyHadithDialog(),
    );
  }
}