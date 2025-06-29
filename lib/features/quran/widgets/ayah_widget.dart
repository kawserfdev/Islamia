import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';

class AyahWidget extends StatelessWidget {
  final AyahModel ayah;
  final String surahName;
  final QuranSettings settings;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onPlay;

  const AyahWidget({
    Key? key,
    required this.ayah,
    required this.surahName,
    required this.settings,
    required this.onBookmark,
    required this.onShare,
    required this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: settings.nightMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Number
          Row(
            children: [
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
              const Spacer(),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onPlay,
                    icon: Icon(
                      Icons.play_arrow,
                      color: Colors.green[700],
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: onBookmark,
                    icon: Icon(
                      Icons.bookmark_border,
                      color: Colors.green[700],
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: onShare,
                    icon: Icon(
                      Icons.share,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(context),
                    icon: Icon(
                      Icons.copy,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Arabic Text
          GestureDetector(
            onTap: () => _showAyahDetails(context),
            child: Text(
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
          ),
          
          const SizedBox(height: 16),
          
          // Translation
          Text(
            ayah.getTranslation(settings.selectedTranslation),
            style: TextStyle(
              fontSize: settings.translationFontSize,
              color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          
          // Transliteration (if enabled)
          if (settings.showTransliteration) ...[
            const SizedBox(height: 8),
            Text(
              _getTransliteration(),
              style: TextStyle(
                fontSize: settings.translationFontSize - 2,
                color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          
          // Tafsir (if enabled)
          if (settings.showTafsir) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Tafsir'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _getTafsir(),
                    style: TextStyle(
                      fontSize: settings.translationFontSize - 1,
                      color: settings.nightMode ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getTransliteration() {
    // This would typically come from an API or local database
    return 'Transliteration not available';
  }

  String _getTafsir() {
    // This would typically come from an API or local database
    return 'Tafsir commentary would be displayed here...';
  }

  void _copyToClipboard(BuildContext context) {
    final text = '${ayah.text}\n\n'
        '${ayah.getTranslation(settings.selectedTranslation)}\n\n'
        '- $surahName ${ayah.numberInSurah}';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ayah copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAyahDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$surahName - Ayah ${ayah.numberInSurah}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Juz: ${ayah.juz}'),
              Text('Page: ${ayah.page}'),
             // Text('Ruku: ${ayah.ruku}'),
              //if (ayah.sajda) const Text('Contains Sajda'),
            ],
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
}