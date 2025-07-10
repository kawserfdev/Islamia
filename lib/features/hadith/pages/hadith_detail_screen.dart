import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:islamia/core/providers/hadith/hadith_providers.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
import 'package:islamia/features/hadith/widgets/share_dialog.dart';

class HadithDetailScreen extends ConsumerStatefulWidget {
  final HadithModel hadith;

  const HadithDetailScreen({Key? key, required this.hadith}) : super(key: key);

  @override
  ConsumerState<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends ConsumerState<HadithDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String _selectedLanguage = 'en';
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hadith ${widget.hadith.hadithNumber}'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return FutureBuilder<bool>(
                future: ref.read(hadithBookmarksProvider.notifier).isBookmarked(widget.hadith.id),
                builder: (context, snapshot) {
                  final isBookmarked = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.amber : Colors.white,
                    ),
                    onPressed: () => _toggleBookmark(isBookmarked),
                  );
                },
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy Text'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Text Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHadithHeader(),
            const SizedBox(height: 16),
            _buildArabicText(),
            const SizedBox(height: 16),
            _buildTranslation(),
            const SizedBox(height: 16),
            _buildNarratorChain(),
            const SizedBox(height: 16),
            _buildGradeInfo(),
            const SizedBox(height: 16),
            _buildReferenceInfo(),
            if (widget.hadith.commentary.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCommentary(),
            ],
            if (widget.hadith.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildTags(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAudio,
        backgroundColor: Colors.green[700],
        child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  Widget _buildHadithHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.hadith.collection,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.hadith.grade.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.hadith.grade.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.hadith.grade.displayName,
                    style: TextStyle(
                      color: widget.hadith.grade.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.hadith.book} - Hadith ${widget.hadith.hadithNumber}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (widget.hadith.chapter.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Chapter: ${widget.hadith.chapter}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArabicText() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Arabic Text',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.volume_up : Icons.volume_off),
                  onPressed: _toggleAudio,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                widget.hadith.arabicText,
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  height: 2.0,
                  fontFamily: 'Noto Naskh Arabic',
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslation() {
    final translation = widget.hadith.getTranslation(_selectedLanguage);
    if (translation.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Translation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (widget.hadith.translations.length > 1)
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
                    items: widget.hadith.translations.keys.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(_getLanguageName(lang)),
                      );
                    }).toList(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              translation,
              style: TextStyle(
                fontSize: _fontSize,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarratorChain() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chain of Narration (Isnad)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.hadith.narratorChain.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  widget.hadith.narratorChain,
                  style: TextStyle(
                    fontSize: _fontSize - 1,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Text(
                'Narrator: ${widget.hadith.narrator}',
                style: TextStyle(
                  fontSize: _fontSize,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authenticity Grade',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.hadith.grade.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.hadith.grade.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getGradeIcon(widget.hadith.grade),
                    color: widget.hadith.grade.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.hadith.grade.displayName,
                      style: TextStyle(
                        color: widget.hadith.grade.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reference',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.hadith.displayReference,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.hadith.reference != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.hadith.reference!,
                style: TextStyle(
                  fontSize: _fontSize - 1,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Commentary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.hadith.commentary.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.hadith.commentary.length > 1)
                    Text(
                      _getLanguageName(entry.key),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: _fontSize - 1,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.hadith.tags.map((tag) => Chip(
                label: Text(
                  tag,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.grey[100],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBookmark(bool isCurrentlyBookmarked) async {
    if (isCurrentlyBookmarked) {
      await ref.read(hadithBookmarksProvider.notifier).removeBookmark(widget.hadith.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed')),
        );
      }
    } else {
      await ref.read(hadithBookmarksProvider.notifier).addBookmark(widget.hadith);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark added')),
        );
      }
    }
    setState(() {}); // Refresh the UI
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      await _flutterTts.speak(widget.hadith.arabicText);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareHadith();
        break;
      case 'copy':
        _copyText();
        break;
      case 'settings':
        _showTextSettings();
        break;
    }
  }

  void _shareHadith() {
    final text = widget.hadith.getShareText(
      languageCode: _selectedLanguage,
      includeNarrator: true,
      includeReference: true,
    );
    
    showDialog(
      context: context,
      builder: (context) => ShareDialog(text: text, hadith: widget.hadith),
    );
  }

  void _copyText() {
    final text = widget.hadith.getShareText(
      languageCode: _selectedLanguage,
      includeNarrator: true,
      includeReference: true,
    );
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _showTextSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Text Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Font Size: '),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
                Text('${_fontSize.round()}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic';
      case 'bn':
        return 'Bengali';
      case 'ur':
        return 'Urdu';
      default:
        return code.toUpperCase();
    }
  }

  IconData _getGradeIcon(HadithGrade grade) {
    switch (grade) {
      case HadithGrade.sahih:
        return Icons.verified;
      case HadithGrade.hasan:
        return Icons.check_circle;
      case HadithGrade.daif:
        return Icons.warning;
      case HadithGrade.maudu:
        return Icons.error;
      case HadithGrade.unknown:
        return Icons.help;
    }
  }
}