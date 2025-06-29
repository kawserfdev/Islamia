import 'package:flutter/material.dart';

class SurahDetailPage extends StatelessWidget {
  final String surahName;

  const SurahDetailPage({super.key, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(surahName),
      ),
      body: Center(
        child: Text('Details for $surahName will be shown here.'),
      ),
    );
  }
}
