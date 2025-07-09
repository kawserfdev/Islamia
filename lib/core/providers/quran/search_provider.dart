import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';

class SearchQuery {
  final String query;
  final int? surahNumber;
  final int? juzNumber;
  final SearchType type;

  const SearchQuery({
    required this.query,
    this.surahNumber,
    this.juzNumber,
    this.type = SearchType.all,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchQuery &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          surahNumber == other.surahNumber &&
          juzNumber == other.juzNumber &&
          type == other.type;

  @override
  int get hashCode =>
      query.hashCode ^
      surahNumber.hashCode ^
      juzNumber.hashCode ^
      type.hashCode;
}

enum SearchType {
  all,
  arabic,
  translation,
  transliteration,
}

final ayahSearchProvider = FutureProvider.family<List<AyahModel>, SearchQuery>((ref, searchQuery) async {
  // This would perform actual search in your database/API
  // For now, return sample search results
  
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
  
  final sampleAyahs = [
    AyahModel(
      number: 1,
      text: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      surahNumber: 1,
      ayahNumber: 1,
      juz: 1,
      manzil: 1,
      page: 1,
      ruku: 1,
      hizbQuarter: 1,
      translations: {
        'en': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      },
      transliterations: {
        'en': 'Bismillahi r-rahmani r-rahim',
      },
      tafsir: {
        'en': 'This is the opening verse of the Quran, known as the Basmala.',
      },
    ),
    // Add more sample ayahs for search results
  ];
  
  // Filter based on search query
  return sampleAyahs.where((ayah) {
    final queryLower = searchQuery.query.toLowerCase();
    
    switch (searchQuery.type) {
      case SearchType.arabic:
        return ayah.text.contains(searchQuery.query);
      case SearchType.translation:
        return ayah.translations.values.any((translation) =>
            translation.toLowerCase().contains(queryLower));
      case SearchType.transliteration:
        return ayah.transliterations!.values.any((transliteration) =>
            transliteration.toLowerCase().contains(queryLower));
      case SearchType.all:
      default:
        return ayah.text.contains(searchQuery.query) ||
            ayah.translations.values.any((translation) =>
                translation.toLowerCase().contains(queryLower)) ||
            ayah.transliterations!.values.any((transliteration) =>
                transliteration.toLowerCase().contains(queryLower));
    }
  }).toList();
});

// Advanced search provider for multiple filters
final advancedSearchProvider = FutureProvider.family<List<AyahModel>, AdvancedSearchQuery>((ref, query) async {
  // Implementation for advanced search with multiple filters
  await Future.delayed(const Duration(milliseconds: 800));
  
  // Return filtered results based on advanced criteria
  return [];
});

class AdvancedSearchQuery {
  final String? text;
  final List<int>? surahNumbers;
  final List<int>? juzNumbers;
  final bool? hasSajda;
  final String? revelationType;
  final DateRange? revelationPeriod;
  
  const AdvancedSearchQuery({
    this.text,
    this.surahNumbers,
    this.juzNumbers,
    this.hasSajda,
    this.revelationType,
    this.revelationPeriod,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;
  
  const DateRange({required this.start, required this.end});
}