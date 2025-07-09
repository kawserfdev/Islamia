//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/audio_provider.dart';
import 'package:islamia/core/providers/quran/bookmark_provider.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/core/services/quran/parameter_classes.dart';
import 'package:islamia/data/models/quran/ayah_audio_model.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';
import 'package:islamia/data/models/quran/juz_model.dart';
import 'package:islamia/features/quran/pages/ayah_search_delegate.dart';
import 'package:islamia/features/quran/widgets/bookmarks_sheet.dart';
import '../widgets/ayah_widget.dart';
import '../widgets/audio_player_widget.dart';
import 'settings_screen.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final Surah? surah;
  final JuzModel? juz;
  final String title;
  final int? initialAyah;

  const QuranReaderScreen({
    Key? key,
    this.surah,
    this.juz,
    required this.title,
    this.initialAyah,
  }) : super(key: key);

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialAyah != null) {
        _scrollToAyah(widget.initialAyah!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(quranSettingsProvider);
    final audioState = ref.watch(audioServiceProvider);

    final ayahsAsync =
        widget.surah != null
            ? ref.watch(
              surahAyahsProvider(
                SurahAyahsParams(surahNumber: widget.surah!.number!),
              ),
            )
            : ref.watch(juzAyahsProvider(widget.juz!.number));

    return Scaffold(
      backgroundColor: settings.nightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor:
            settings.nightMode ? Colors.grey[900] : Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showReaderMenu(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Player Widget
          audioState.isInitialized
              ? AudioPlayerWidget(
                surahNumber: widget.surah?.number ?? 0,
                totalAyahs: widget.surah!.numberOfAyahs??0,
              )
              : const SizedBox.shrink(),
          // audioPlayerAsync.when(
          //   data:
          //       (audioState) =>
          //           audioState.isInitialized
          //               ? AudioPlayerWidget(audioState: audioState)
          //               : const SizedBox.shrink(),
          //   loading: () => const SizedBox.shrink(),
          //   error: (_, __) => const SizedBox.shrink(),
          // ),

          // Ayah Content
          Expanded(
            child: ayahsAsync.when(
              data: (ayahs) => _buildAyahsList(ayahs, settings),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text('Error loading content: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.surah != null) {
                              ref.refresh(
                                surahAyahsProvider(
                                  SurahAyahsParams(
                                    surahNumber: widget.surah!.number!,
                                  ),
                                ),
                              );
                            } else {
                              ref.refresh(juzAyahsProvider(widget.juz!.number));
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(settings),
    );
  }

  Widget _buildAyahsList(List<AyahModel> ayahs, QuranSettings settings) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: ayahs.length,
      itemBuilder: (context, index) {
        final ayah = ayahs[index];
        _ayahKeys[ayah.ayahNumber] = GlobalKey();

        return AyahWidget(
          key: _ayahKeys[ayah.ayahNumber],
          ayah: ayah,
          settings: settings,
          onBookmark: () => _toggleBookmark(ayah),
          onPlay: () => _playAyah(ayah),
          onShare: () => _shareAyah(ayah),
          surahName: ayah.text,
          //onTafsir: () => _showTafsir(ayah),
        );
      },
    );
  }

  Widget _buildFloatingActionButtons(QuranSettings settings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "settings",
          mini: true,
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuranSettingsScreen(),
                ),
              ),
          backgroundColor: Colors.green[700],
          child: const Icon(Icons.settings, color: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "bookmarks",
          mini: true,
          onPressed: () => _showBookmarksSheet(),
          backgroundColor: Colors.amber[700],
          child: const Icon(Icons.bookmark, color: Colors.white),
        ),
      ],
    );
  }

  void _showReaderMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Search in Surah'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSearch(ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('My Bookmarks'),
                  onTap: () {
                    Navigator.pop(context);
                    _showBookmarksSheet();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share Surah'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareSurah();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Surah Info'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSurahInfo();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleBookmark(AyahModel ayah) {
    final bookmarkNotifier = ref.read(bookmarksProvider.notifier);

    final bookmark = BookmarkModel(
      id: '${ayah.surahNumber}:${ayah.ayahNumber}',
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      category: 'Default',
      tags: [],
      note: null,
      surahName: ayah.text,
      ayahText: ayah.text,
      createdAt: DateTime.now(),
    );

    final wasBookmarked = bookmarkNotifier.state.isAyahBookmarked(
      ayah.surahNumber,
      ayah.ayahNumber,
    );

    bookmarkNotifier.toggleBookmark(bookmark);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmark ${wasBookmarked ? 'removed' : 'added'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playAyah(AyahModel ayah) {
    final audioNotifier = ref.read(audioServiceProvider.notifier);
    audioNotifier.playAyah(
      ayah.audioUrl ?? "",
      ayah.ayahNumber,
      ayah.surahNumber,
    );
  }

  void _shareAyah(AyahModel ayah) {
    final text = '''
${ayah.text}

${ayah.translations['en'] ?? ''}

Surah ${ayah.surahNumber}, Ayah ${ayah.ayahNumber}
From Islamia App
''';
    // Share.share(text); // Uncomment when share_plus is added
    print('Sharing: $text');
  }

  void _showTafsir(AyahModel ayah) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Tafsir - ${ayah.surahNumber}:${ayah.ayahNumber}'),
            content: SingleChildScrollView(
              child: Text(
                ayah.getTafsir("en") ?? 'Tafsir not available for this ayah.',
              ),
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

  void _showSearch(WidgetRef ref) {
    // Navigate to search screen or show search dialog
    showSearch(
      context: context,
      delegate: AyahSearchDelegate(
        surahNumber: widget.surah?.number,
        juzNumber: widget.juz?.number,
        ref: ref,
      ),
    );
  }

  void _showBookmarksSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => BookmarksSheet(
                  scrollController: scrollController,
                  onAyahSelected: (ayah) {
                    Navigator.pop(context);
                    _scrollToAyah(ayah.ayahNumber);
                  },
                ),
          ),
    );
  }

  void _shareSurah() {
    final title = widget.surah?.name ?? widget.juz?.name ?? widget.title;
    final text = '''
Check out $title in the Islamia App!
Download now for complete Quran reading experience.
''';
    // Share.share(text);
    print('Sharing: $text');
  }

  void _showSurahInfo() {
    if (widget.surah == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(widget.surah?.name ?? widget.juz?.name ?? widget.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('English Name: ${widget.surah!.englishName}'),
                Text('Translation: ${widget.surah!.englishNameTranslation}'),
                Text('Number of Ayahs: ${widget.surah!.numberOfAyahs}'),
                Text('Revelation: ${widget.surah!.revelationType}'),
                Text('Juz: ${widget.juz?.name}'),
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

// Provider for Juz Ayahs
final juzAyahsProvider = FutureProvider.family<List<AyahModel>, int>((
  ref,
  juzNumber,
) async {
  // This would fetch ayahs for the specific Juz from API/database
  // For now, return sample data
  return List.generate(200, (index) {
    return AyahModel(
      number: (juzNumber - 1) * 200 + index + 1,
      text: 'Sample Arabic text for Juz $juzNumber, Ayah ${index + 1}',
      surahNumber: (index ~/ 20) + 1,
      ayahNumber: (index % 20) + 1,
      juz: juzNumber,
      manzil: ((juzNumber - 1) ~/ 4) + 1,
      page: ((juzNumber - 1) * 20) + (index ~/ 10) + 1,
      ruku: (index ~/ 5) + 1,
      hizbQuarter: ((juzNumber - 1) * 8) + (index ~/ 25) + 1,
      translations: {
        'en': 'Sample English translation for this ayah.',
        'bn': 'এই আয়াতের জন্য নমুনা বাংলা অনুবাদ।',
      },
      transliterations: {'en': 'Sample transliteration for this ayah.'},
      tafsir: {
        'en':
            'Sample tafsir commentary for this ayah explaining its meaning and context.',
      },
    );
  });
});
