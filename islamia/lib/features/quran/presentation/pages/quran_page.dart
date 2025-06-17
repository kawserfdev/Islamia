import 'package:flutter/material.dart';
import 'package:islamia/features/quran/presentation/pages/surah_list_page.dart'; // Assuming surah_list_page.dart will be in the same directory

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SurahListPage()),
            );
          },
          child: const Text('View Surah List'),
        ),
      ),
    );
  }
}
