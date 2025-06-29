// Placeholder for surah_tile.dart
import 'package:flutter/material.dart';
import 'package:islamia/data/models/quran/surah_model.dart';

class SurahTile extends StatelessWidget {
  final SurahModel surah;
  final bool nightMode;
  final VoidCallback onTap;

  const SurahTile({
    Key? key,
    required this.surah,
    required this.nightMode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: nightMode ? Colors.grey[800] : Colors.white,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Surah Number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            surah.englishName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: nightMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          surah.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontFamily: 'Arabic',
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: surah.isMakki ? Colors.amber[100] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            surah.revelationType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: surah.isMakki ? Colors.amber[800] : Colors.blue[800],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${surah.numberOfAyahs} Ayahs',
                          style: TextStyle(
                            fontSize: 12,
                            color: nightMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      surah.englishNameTranslation,
                      style: TextStyle(
                        fontSize: 14,
                        color: nightMode ? Colors.grey[300] : Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: nightMode ? Colors.grey[400] : Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}