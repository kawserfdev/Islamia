import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/hadith/hadith_providers.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
import 'hadith_detail_screen.dart';

class HadithSearchScreen extends ConsumerStatefulWidget {
  const HadithSearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends ConsumerState<HadithSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';
  String _selectedCollection = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _currentQuery.isNotEmpty 
        ? ref.watch(hadithSearchProvider(SearchParams(
            query: _currentQuery,
            collectionId: _selectedCollection.isNotEmpty ? _selectedCollection : null,
          )))
        : const AsyncValue.data(<HadithModel>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hadiths'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: searchResults.when(
              data: (hadiths) => _buildSearchResults(hadiths),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search hadiths...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _currentQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (query) {
              setState(() {
                _currentQuery = query;
              });
            },
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final collectionsAsync = ref.watch(hadithCollectionsProvider);
              return collectionsAsync.when(
                data: (collections) => DropdownButtonFormField<String>(
                  value: _selectedCollection.isEmpty ? null : _selectedCollection,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Collection',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All Collections'),
                    ),
                    ...collections.map((collection) => DropdownMenuItem(
                      value: collection.id,
                      child: Text(collection.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCollection = value ?? '';
                    });
                  },
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<HadithModel> hadiths) {
    if (_currentQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Enter a search term to find hadiths',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
           
        ),
      );
    }

    if (hadiths.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hadiths found',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Try different search terms',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: hadiths.length,
      itemBuilder: (context, index) {
        final hadith = hadiths[index];
        return _buildSearchResultCard(hadith);
      },
    );
  }

  Widget _buildSearchResultCard(HadithModel hadith) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => _navigateToDetail(hadith),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${hadith.collection} - Hadith ${hadith.hadithNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hadith.grade.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hadith.grade.displayName.split(' ')[0],
                      style: TextStyle(
                        color: hadith.grade.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hadith.arabicText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Noto Naskh Arabic',
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (hadith.translations.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  hadith.getTranslation('en'),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Narrator: ${hadith.narrator}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          Text('Search failed', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _navigateToDetail(HadithModel hadith) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HadithDetailScreen(hadith: hadith),
      ),
    );
  }
}