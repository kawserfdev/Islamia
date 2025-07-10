import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/hadith/hadith_providers.dart';
import 'package:islamia/data/models/hadith/hadith_category.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
import 'package:islamia/features/hadith/pages/hadith_detail_screen.dart';

class CategoryHadithsScreen extends ConsumerWidget {
  final HadithCategory category;

  const CategoryHadithsScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadithsAsync = ref.watch(categoryHadithsProvider(CategoryParams(
      categoryId: category.id,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name),
            Text(
              '${category.hadithCount} Hadiths',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: hadithsAsync.when(
        data: (hadiths) => _buildHadithsList(context, hadiths),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error.toString(), ref),
      ),
    );
  }

  Widget _buildHadithsList(BuildContext context, List<HadithModel> hadiths) {
    if (hadiths.isEmpty) {
      return const Center(
        child: Text('No hadiths found in this category'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: hadiths.length,
      itemBuilder: (context, index) {
        final hadith = hadiths[index];
        return _buildHadithCard(context, hadith);
      },
    );
  }

  Widget _buildHadithCard(BuildContext context, HadithModel hadith) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => _navigateToDetail(context, hadith),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${hadith.collection} - Hadith ${hadith.hadithNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hadith.grade.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hadith.grade.displayName.split(' ')[0],
                      style: TextStyle(
                        color: hadith.grade.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hadith.arabicText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Noto Naskh Arabic',
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (hadith.translations.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  hadith.getTranslation('en'),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Failed to load hadiths', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(categoryHadithsProvider(CategoryParams(
              categoryId: category.id,
            ))),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, HadithModel hadith) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HadithDetailScreen(hadith: hadith),
      ),
    );
  }
}