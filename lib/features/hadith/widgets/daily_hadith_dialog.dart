import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/hadith/hadith_providers.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
import 'package:islamia/features/hadith/pages/hadith_detail_screen.dart';
class DailyHadithDialog extends ConsumerWidget {
  const DailyHadithDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyHadithAsync = ref.watch(dailyHadithProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Daily Hadith',
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
            Expanded(
              child: dailyHadithAsync.when(
                data: (hadith) => _buildHadithContent(context, ref, hadith),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithContent(BuildContext context, WidgetRef ref, HadithModel hadith) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              hadith.arabicText,
              style: const TextStyle(
                fontSize: 18,
                height: 1.8,
                fontFamily: 'Noto Naskh Arabic',
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 12),
          if (hadith.translations.isNotEmpty)
            Text(
              hadith.getTranslation('en'),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hadith.collection,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hadith.grade.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: hadith.grade.color.withOpacity(0.3)),
                ),
                child: Text(
                  hadith.grade.displayName.split(' ')[0],
                  style: TextStyle(
                    color: hadith.grade.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Narrator: ${hadith.narrator}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _bookmarkHadith(context, ref, hadith),
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Bookmark'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewFullHadith(context, hadith),
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('View Full'),
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
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Failed to load daily hadith', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.refresh(dailyHadithProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _bookmarkHadith(BuildContext context, WidgetRef ref, HadithModel hadith) async {
    try {
      await ref.read(hadithBookmarksProvider.notifier).addBookmark(hadith);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily hadith bookmarked!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to bookmark: $e')),
      );
    }
  }

  void _viewFullHadith(BuildContext context, HadithModel hadith) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HadithDetailScreen(hadith: hadith),
      ),
    );
  }
}