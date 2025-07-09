import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:islamia/core/providers/quran/quran_provider.dart';
import 'package:islamia/core/providers/quran/reading_history_provider.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/surah_model.dart';
import 'package:islamia/features/quran/pages/bookmarks_screen.dart';
import 'package:islamia/features/quran/pages/search_screen.dart';
import 'package:islamia/features/quran/pages/settings_screen.dart';
import '../widgets/surah_tile.dart';
import 'quran_reader_screen.dart';

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<SurahModel> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahListAsync = ref.watch(surahListProvider);
    final settings = ref.watch(quranSettingsProvider);

    return Scaffold(
      backgroundColor: settings.nightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Holy Quran'),
        backgroundColor: settings.nightMode ? Colors.grey[900] : Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuranBookmarksScreen()),
            ),
            icon: const Icon(Icons.bookmark),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: const Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'night_mode',
                child: Row(
                  children: [
                    Icon(settings.nightMode ? Icons.light_mode : Icons.dark_mode),
                    const SizedBox(width: 8),
                    Text(settings.nightMode ? 'Light Mode' : 'Night Mode'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuranSettingsScreen()),
                  );
                  break;
                case 'night_mode':
                  ref.read(quranSettingsProvider.notifier).setNightMode(!settings.nightMode);
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Surahs'),
            Tab(text: 'Juz'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: settings.nightMode ? Colors.grey[900] : Colors.green[700],
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Surahs...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Surahs Tab
                surahListAsync.when(
                  data: (surahs) => _buildSurahList(surahs, settings),
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
                          'Failed to load Surahs',
                          style: TextStyle(
                            fontSize: 18,
                            color: settings.nightMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref.refresh(surahListProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Juz Tab
                _buildJuzList(settings),
                
                // Recent Tab
                _buildRecentReadings(settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(List<SurahModel> surahs, QuranSettings settings) {
    final filteredSurahs = _searchQuery.isEmpty
        ? surahs
        : surahs.where((surah) =>
            surah.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            surah.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            surah.englishNameTranslation.toLowerCase().contains(_searchQuery.toLowerCase()),
          ).toList();

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredSurahs.length,
        itemBuilder: (context, index) {
          final surah = filteredSurahs[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: SurahTile(
                  surah: surah,
                  nightMode: settings.nightMode,
                  onTap: () => _navigateToReader(surah),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJuzList(QuranSettings settings) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: settings.nightMode ? Colors.grey[800] : Colors.white,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$juzNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              'Juz $juzNumber',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: settings.nightMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              'Para $juzNumber',
              style: TextStyle(
                color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
              size: 16,
            ),
            onTap: () {
              // Navigate to Juz reader
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening Juz $juzNumber')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentReadings(QuranSettings settings) {
    final recentSessionsAsync = ref.watch(recentSessionsProvider(10));
    
    return recentSessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: settings.nightMode ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent readings',
                  style: TextStyle(
                    fontSize: 18,
                    color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start reading to see your history here',
                  style: TextStyle(
                    color: settings.nightMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: settings.nightMode ? Colors.grey[800] : Colors.white,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${session.surahNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Surah ${session.surahNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: settings.nightMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last read: Ayah ${session.lastAyahRead}',
                      style: TextStyle(
                        color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Reading time: ${_formatDuration(session.totalReadingTime)}',
                      style: TextStyle(
                        color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.play_arrow,
                  color: Colors.green[700],
                ),
                onTap: () {
                  // Navigate to continue reading
                  // _navigateToReaderWithPosition(session.surahNumber, session.lastAyahRead);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load recent readings',
          style: TextStyle(
            color: settings.nightMode ? Colors.red[300] : Colors.red,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  void _navigateToReader(SurahModel surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranReaderScreen(title: surah.name, surah: surah),
      ),
    );
  }
}
