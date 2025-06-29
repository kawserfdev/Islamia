import 'package:flutter/material.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';

class SearchResultTile extends StatelessWidget {
  final AyahModel ayah;
  final String searchQuery;
  final QuranSettings settings;
  final VoidCallback onTap;

  const SearchResultTile({
    Key? key,
    required this.ayah,
    required this.searchQuery,
    required this.settings,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: settings.nightMode ? Colors.grey[800] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Surah and Ayah info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Surah ${ayah.surahNumber}:${ayah.numberInSurah}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Juz ${ayah.juz} • Page ${ayah.page}',
                    style: TextStyle(
                      fontSize: 12,
                      color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Arabic text
              Text(
                ayah.text,
                style: TextStyle(
                  fontSize: settings.arabicFontSize - 4,
                  fontFamily: settings.fontFamily,
                  color: settings.nightMode ? Colors.white : Colors.black,
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              
              const SizedBox(height: 8),
              
              // Translation with highlighting
              RichText(
                text: _buildHighlightedText(
                  ayah.getTranslation(settings.selectedTranslation),
                  searchQuery,
                  settings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(String text, String query, QuranSettings settings) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(
          fontSize: settings.translationFontSize,
          color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
        ),
      );
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            fontSize: settings.translationFontSize,
            color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          fontSize: settings.translationFontSize,
          color: Colors.green[700],
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.yellow[200],
        ),
      ));
      
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(
          fontSize: settings.translationFontSize,
          color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
        ),
      ));
    }
    
    return TextSpan(children: spans);
  }
}