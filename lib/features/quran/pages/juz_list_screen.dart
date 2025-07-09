import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/juz_model.dart';
import 'package:islamia/data/models/quran/surah_range.dart';
import 'quran_reader_screen.dart';

class JuzListScreen extends ConsumerWidget {
  const JuzListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzListAsync = ref.watch(juzListProvider);
    final settings = ref.watch(quranSettingsProvider);

    return Scaffold(
      backgroundColor: settings.nightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Juz / Para'),
        backgroundColor: settings.nightMode ? Colors.grey[900] : Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: juzListAsync.when(
        data: (juzList) => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: juzList.length,
          itemBuilder: (context, index) {
            final juz = juzList[index];
            return _buildJuzCard(context, juz, settings);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text('Error loading Juz list: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(juzListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJuzCard(BuildContext context, JuzModel juz, QuranSettings settings) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: settings.nightMode ? Colors.grey[800] : Colors.white,
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToJuzReader(context, juz),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Juz Number Circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${juz.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Juz Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      juz.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: settings.nightMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${juz.totalAyahs} Ayahs • ${juz.surahs.length} Surahs',
                      style: TextStyle(
                        fontSize: 14,
                        color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSurahChips(juz.surahs, settings),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahChips(List<SurahInJuz> surahs, QuranSettings settings) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: surahs.take(3).map((surahRange) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: settings.nightMode ? Colors.grey[700] : Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: settings.nightMode ? Colors.grey[600]! : Colors.green[200]!,
            ),
          ),
          child: Text(
            surahRange.surahName,
            style: TextStyle(
              fontSize: 12,
              color: settings.nightMode ? Colors.green[300] : Colors.green[700],
            ),
          ),
        );
      }).toList()
        ..addAll(surahs.length > 3 ? [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: settings.nightMode ? Colors.grey[700] : Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: settings.nightMode ? Colors.grey[600]! : Colors.green[200]!,
            ),
          ),
            child: Text(
              '+${surahs.length - 3} more',
              style: TextStyle(
                fontSize: 12,
                color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ] : []),
    );
  }

  void _navigateToJuzReader(BuildContext context, JuzModel juz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranReaderScreen(
          juz: juz,
          title: juz.name,
         // surah: juz.surahs,
        ),
      ),
    );
  }
}

// Provider for Juz list
final juzListProvider = FutureProvider<List<JuzModel>>((ref) async {
  // This would typically fetch from an API or local database
  // For now, return sample data
  return List.generate(30, (index) {
    final juzNumber = index + 1;
    return JuzModel(
      number: juzNumber,
      name: 'Juz $juzNumber',
      surahs: _getSampleSurahRanges(juzNumber),
      startAyahNumber: (juzNumber - 1) * 200 + 1,
      endAyahNumber: juzNumber * 200,
      totalAyahs: 200,
    );
  });
});

List<SurahInJuz> _getSampleSurahRanges(int juzNumber) {
  // This is sample data - in real implementation, this would come from a database
  final sampleRanges = [
    SurahInJuz(surahNumber: 1, surahName: 'Al-Fatihah', startVerse: 1, endVerse: 7),
    SurahInJuz(surahNumber: 2, surahName: 'Al-Baqarah', startVerse: 1, endVerse: 141),
    SurahInJuz(surahNumber: 3, surahName: 'Ali-Imran', startVerse: 1, endVerse: 92),
  ];
  
  return sampleRanges.take(2).toList();
}