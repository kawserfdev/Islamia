import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';

class ShareDialog extends StatefulWidget {
  final String text;
  final HadithModel hadith;

  const ShareDialog({
    Key? key,
    required this.text,
    required this.hadith,
  }) : super(key: key);

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  bool _includeArabic = true;
  bool _includeTranslation = true;
  bool _includeNarrator = true;
  bool _includeReference = true;
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Share Hadith',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Share options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Include Arabic Text'),
                      value: _includeArabic,
                      onChanged: (value) => setState(() => _includeArabic = value),
                      dense: true,
                    ),
                    SwitchListTile(
                      title: const Text('Include Translation'),
                      value: _includeTranslation,
                      onChanged: (value) => setState(() => _includeTranslation = value),
                      dense: true,
                    ),
                    SwitchListTile(
                      title: const Text('Include Narrator'),
                      value: _includeNarrator,
                      onChanged: (value) => setState(() => _includeNarrator = value),
                      dense: true,
                    ),
                    SwitchListTile(
                      title: const Text('Include Reference'),
                      value: _includeReference,
                      onChanged: (value) => setState(() => _includeReference = value),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preview
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _generateShareText(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareText,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    
    if (_includeArabic) {
      buffer.writeln(widget.hadith.arabicText);
      buffer.writeln();
    }
    
    if (_includeTranslation && widget.hadith.translations.isNotEmpty) {
      final translation = widget.hadith.getTranslation(_selectedLanguage);
      if (translation.isNotEmpty) {
        buffer.writeln(translation);
        buffer.writeln();
      }
    }
    
    if (_includeNarrator) {
      buffer.writeln('Narrator: ${widget.hadith.narrator}');
      buffer.writeln();
    }
    
    if (_includeReference) {
      buffer.writeln('Reference: ${widget.hadith.displayReference}');
      buffer.writeln('Grade: ${widget.hadith.grade.displayName}');
    }
    
    return buffer.toString().trim();
  }

  void _copyToClipboard() {
    final text = _generateShareText();
    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _shareText() {
    final text = _generateShareText();
    // Implement actual sharing using share plugin
    // Share.share(text);
    Navigator.pop(context);
  }
}