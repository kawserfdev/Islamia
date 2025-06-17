import 'package:flutter/material.dart';
import 'package:islamia/features/quran/presentation/pages/surah_detail_page.dart'; // Assuming surah_detail_page.dart will be in the same directory

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  // Static list of Surah names (first 10 for now)
  final List<String> surahNames = const [
    'Al-Fatiha',
    'Al-Baqarah',
    'Aal-Imran',
    'An-Nisa',
    'Al-Maidah',
    'Al-Anam',
    'Al-Araf',
    'Al-Anfal',
    'At-Tawbah',
    'Yunus',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Surahs'),
      ),
      body: ListView.builder(
        itemCount: surahNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(surahNames[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahDetailPage(surahName: surahNames[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
