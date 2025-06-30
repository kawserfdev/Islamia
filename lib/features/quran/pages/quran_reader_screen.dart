import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/audio_provider.dart';
import 'package:islamia/core/providers/quran/bookmark_provider.dart' hide surahAyahsProvider;
import 'package:islamia/core/providers/quran/quran_provider.dart';
import 'package:islamia/core/providers/quran/reading_history_provider.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
import 'package:islamia/data/models/quran/surah_model.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/ayah_widget.dart';
import '../widgets/audio_player_widget.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final SurahModel surah;
  final int? startFromAyah;

  const QuranReaderScreen({
    Key? key,
    required this.surah,
    this.startFromAyah,
  }) : super(key: key);

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  DateTime? _sessionStartTime;
  
  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    
    // Scroll to specific ayah if provided
    if (widget.startFromAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(widget.startFromAyah!);
      });
    }
  }

  @override
  void dispose() {
    _updateReadingSession();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateReadingSession() {
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      ref.read(readingHistoryProvider.notifier).updateSession(
        surahNumber: widget.surah.number,
        lastAyahRead: 1, // You can track this more precisely
        additionalTime: sessionDuration,
      );
    }
  }

  void _scrollToAyah(int ayahNumber) {
    // Implementation for scrolling to specific ayah
    // This would require tracking ayah positions
  }

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(surahAyahsProvider(widget.surah.number));
    final settings = ref.watch(quranSettingsProvider);
    final audioState = ref.watch(audioServiceProvider);

    return Scaffold(
      backgroundColor: settings.nightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surah.englishName,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              widget.surah.name,
              style: const TextStyle(fontSize: 14, fontFamily: 'Arabic'),
            ),
          ],
        ),
        backgroundColor: settings.nightMode ? Colors.grey[900] : Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showReaderOptions(context),
            icon: const Icon(Icons.text_fields),
          ),
          IconButton(
            onPressed: () => _shareCurrentPage(),
            icon: const Icon(Icons.share),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bookmarks',
                child: Row(
                  children: [
                    Icon(Icons.bookmark),
                    SizedBox(width: 8),
                    Text('Bookmarks'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Search in Surah'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Surah Info'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'bookmarks':
                  _showBookmarksInSurah();
                  break;
                case 'search':
                  _showSearchInSurah();
                  break;
                case 'info':
                  _showSurahInfo();
                  break;
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AudioPlayerWidget(
            surahNumber: widget.surah.number,
            totalAyahs: widget.surah.numberOfAyahs,
          ),
        ),
      ),
      body: ayahsAsync.when(
        data: (ayahs) => _buildReaderContent(ayahs, settings),
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
                'Failed to load Surah',
                style: TextStyle(
                  fontSize: 18,
                  color: settings.nightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(surahAyahsProvider(widget.surah.number)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scrollToTop(),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
      ),
    );
  }

  Widget _buildReaderContent(List<AyahModel> ayahs, QuranSettings settings) {
    if (settings.dualColumnLayout) {
      return _buildDualColumnLayout(ayahs, settings);
    } else {
      return _buildSingleColumnLayout(ayahs, settings);
    }
  }

  Widget _buildSingleColumnLayout(List<AyahModel> ayahs, QuranSettings settings) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: ayahs.length + 1, // +1 for Bismillah
      itemBuilder: (context, index) {
        if (index == 0 && widget.surah.number != 1 && widget.surah.number != 9) {
          // Bismillah (except for Al-Fatiha and At-Tawbah)
          return _buildBismillah(settings);
        }

        final ayahIndex = widget.surah.number == 1 || widget.surah.number == 9 ? index : index - 1;
        if (ayahIndex >= ayahs.length) return const SizedBox();

        final ayah = ayahs[ayahIndex];
        return AyahWidget(
          ayah: ayah,
          surahName: widget.surah.englishName,
          settings: settings,
          onBookmark: () => _toggleBookmark(ayah),
          onShare: () => _shareAyah(ayah),
          onPlay: () => _playAyah(ayah),
        );
      },
    );
  }

  Widget _buildDualColumnLayout(List<AyahModel> ayahs, QuranSettings settings) {
    return Row(
      children: [
        // Arabic Column
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ayah.text,
                      style: TextStyle(
                        fontSize: settings.arabicFontSize,
                        fontFamily: settings.fontFamily,
                        color: settings.nightMode ? Colors.white : Colors.black,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${ayah.numberInSurah}',
                          style: const TextStyle(
                                                   color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const VerticalDivider(width: 1),
        
        // Translation Column
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ayah.getTranslation(settings.selectedTranslation),
                      style: TextStyle(
                        fontSize: settings.translationFontSize,
                        color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _toggleBookmark(ayah),
                          icon: Icon(
                            Icons.bookmark,
                            size: 20,
                            color: Colors.green[700],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _shareAyah(ayah),
                          icon: const Icon(
                            Icons.share,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _playAyah(ayah),
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBismillah(QuranSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.nightMode ? Colors.grey[800] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green[200]!,
          width: 1,
        ),
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        style: TextStyle(
          fontSize: settings.arabicFontSize + 4,
          fontFamily: settings.fontFamily,
          color: Colors.green[700],
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  void _showReaderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ReaderOptionsSheet(),
    );
  }

  void _shareCurrentPage() {
    Share.share(
      'Reading ${widget.surah.englishName} (${widget.surah.name}) from Islamia App',
    );
  }

  void _shareAyah(AyahModel ayah) {
    final text = '${ayah.text}\n\n'
        '${ayah.getTranslation(ref.read(quranSettingsProvider).selectedTranslation)}\n\n'
        '- ${widget.surah.englishName} ${ayah.numberInSurah}:${widget.surah.number}';
    Share.share(text);
  }

  Future<void> _toggleBookmark(AyahModel ayah) async {
    final bookmarkId = '${widget.surah.number}_${ayah.numberInSurah}';
    // final isBookmarked = await ref.read(bookmarksProvider.notifier).isBookmarked(
    //   widget.surah.number,
    //   ayah.numberInSurah,
    // );

    // if (isBookmarked) {
    //   await ref.read(bookmarksProvider.notifier).removeBookmark(bookmarkId);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Bookmark removed')),
    //   );
    // } else {
    //   final bookmark = BookmarkModel(
    //     id: bookmarkId,
    //     surahNumber: widget.surah.number,
    //     ayahNumber: ayah.numberInSurah,
    //     surahName: widget.surah.englishName,
    //     ayahText: ayah.text,
    //     createdAt: DateTime.now(),
    //   );
      
    //   await ref.read(bookmarksProvider.notifier).addBookmark(bookmark);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Bookmark added')),
    //   );
    // }
  }

  void _playAyah(AyahModel ayah) {
    final reciter = ref.read(quranSettingsProvider).selectedReciter;
    final audioUrl = 'https://api.alquran.cloud/v1/ayah/${ayah.number}/$reciter';
    
    ref.read(audioServiceProvider.notifier).playAyah(
      audioUrl,
      widget.surah.number,
      ayah.numberInSurah,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showBookmarksInSurah() {
    // Implementation for showing bookmarks in current surah
  }

  void _showSearchInSurah() {
    // Implementation for searching within current surah
  }

  void _showSurahInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.surah.englishName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arabic Name: ${widget.surah.name}'),
            Text('Meaning: ${widget.surah.englishNameTranslation}'),
            Text('Number of Ayahs: ${widget.surah.numberOfAyahs}'),
            Text('Revelation: ${widget.surah.revelationType}'),
            if (widget.surah.revelationOrder != null)
              Text('Revelation Order: ${widget.surah.revelationOrder}'),
          ],
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
}

// Reader Options Sheet
class ReaderOptionsSheet extends ConsumerWidget {
  const ReaderOptionsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quranSettingsProvider);
    final settingsNotifier = ref.read(quranSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reading Options',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          
          // Arabic Font Size
          Row(
            children: [
              const Text('Arabic Font Size'),
              const Spacer(),
              Text('${settings.arabicFontSize.round()}'),
            ],
          ),
          Slider(
            value: settings.arabicFontSize,
            min: 14,
            max: 40,
            divisions: 26,
            onChanged: (value) => settingsNotifier.setArabicFontSize(value),
          ),
          
          // Translation Font Size
          Row(
            children: [
              const Text('Translation Font Size'),
              const Spacer(),
              Text('${settings.translationFontSize.round()}'),
            ],
          ),
          Slider(
            value: settings.translationFontSize,
            min: 12,
            max: 24,
            divisions: 12,
            onChanged: (value) => settingsNotifier.setTranslationFontSize(value),
          ),
          
          // Night Mode Toggle
          SwitchListTile(
            title: const Text('Night Mode'),
            value: settings.nightMode,
            onChanged: (value) => settingsNotifier.setNightMode(value),
          ),
          
          // Dual Column Layout
          SwitchListTile(
            title: const Text('Dual Column Layout'),
            value: settings.dualColumnLayout,
            onChanged: (value) => settingsNotifier.setDualColumnLayout(value),
          ),
          
          // Show Transliteration
          SwitchListTile(
            title: const Text('Show Transliteration'),
            value: settings.showTransliteration,
            onChanged: (value) => settingsNotifier.setShowTransliteration(value),
          ),
        ],
      ),
    );
  }
}