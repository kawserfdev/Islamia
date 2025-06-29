import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:islamia/core/providers/quran/quran_provider.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import '../widgets/search_result_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(quranSettingsProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider(_currentQuery));

    return Scaffold(
      backgroundColor: settings.nightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: settings.nightMode ? Colors.grey[900] : Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Search Quran'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.all(16),
            color: settings.nightMode ? Colors.grey[900] : Colors.green[700],
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search in Quran...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _currentQuery = '';
                            _isSearching = false;
                          });
                        },
                        icon: const Icon(Icons.clear, color: Colors.white70),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (value) {
                if (value.length >= 3) {
                  setState(() {
                    _currentQuery = value;
                    _isSearching = true;
                  });
                } else {
                  setState(() {
                    _currentQuery = '';
                    _isSearching = false;
                  });
                }
              },
              onSubmitted: (value) {
                if (value.length >= 3) {
                  setState(() {
                    _currentQuery = value;
                    _isSearching = true;
                  });
                }
              },
            ),
          ),

          // Search Tips
          if (!_isSearching && _currentQuery.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: settings.nightMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search the Holy Quran',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: settings.nightMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter at least 3 characters to search',
                      style: TextStyle(
                        color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSearchTips(settings),
                  ],
                ),
              ),
            ),

          // Search Results
          if (_isSearching && _currentQuery.isNotEmpty)
            Expanded(
              child: searchResultsAsync.when(
                data: (results) => _buildSearchResults(results, settings),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: settings.nightMode ? Colors.red[300] : Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search Error',
                        style: TextStyle(
                          fontSize: 18,
                          color: settings.nightMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to search: ${error.toString()}',
                        style: TextStyle(
                          color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(searchResultsProvider(_currentQuery)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTips(QuranSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.nightMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Tips:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: settings.nightMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildTipItem('• Search in Arabic or English', settings),
          _buildTipItem('• Use keywords like "prayer", "faith", "mercy"', settings),
          _buildTipItem('• Search for specific terms or phrases', settings),
          _buildTipItem('• Results show verse context and location', settings),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, QuranSettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<AyahModel> results, QuranSettings settings) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: settings.nightMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: settings.nightMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different search terms',
              style: TextStyle(
                color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results Count
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: settings.nightMode ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                'for "$_currentQuery"',
                style: TextStyle(
                  color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Results List
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final ayah = results[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: SearchResultTile(
                        ayah: ayah,
                        searchQuery: _currentQuery,
                        settings: settings,
                        onTap: () => _navigateToAyah(ayah),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToAyah(AyahModel ayah) {
    // Navigate to the specific ayah in the reader
    Navigator.pop(context, ayah);
  }
}
