import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/hadith/hadith_providers.dart';
import 'package:islamia/data/models/hadith/hadith_category.dart';
import 'package:islamia/features/hadith/pages/category_hadiths_screen.dart';

class HadithCategoriesScreen extends ConsumerWidget {
  const HadithCategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(hadithCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Categories'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: categoriesAsync.when(
        data: (categories) => _buildCategoriesList(context, categories),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error.toString(), ref),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, List<HadithCategory> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, HadithCategory category) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => _navigateToCategory(context, category),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getCategoryIcon(category.iconName),
                  color: Colors.green[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (category.arabicName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.arabicName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'Noto Naskh Arabic',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.hadithCount}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hadiths',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
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
          Text('Failed to load categories', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(hadithCategoriesProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToCategory(BuildContext context, HadithCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryHadithsScreen(category: category),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'prayer':
        return Icons.mosque;
      case 'fasting':
        return Icons.schedule;
      case 'charity':
        return Icons.volunteer_activism;
      case 'pilgrimage':
        return Icons.location_on;
      case 'marriage':
        return Icons.favorite;
      case 'knowledge':
        return Icons.school;
      case 'faith':
        return Icons.favorite_border;
      case 'manners':
        return Icons.handshake;
      default:
        return Icons.book;
    }
  }
}
