
// Parameter Classes


import 'package:islamia/core/providers/quran/bookmark_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SurahAyahsParams {
  final int surahNumber;
  final String arabicEdition;
  final String translationEdition;

  const SurahAyahsParams({
    required this.surahNumber,
    this.arabicEdition = 'ar.alafasy',
    this.translationEdition = 'en.sahih',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahAyahsParams &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          arabicEdition == other.arabicEdition &&
          translationEdition == other.translationEdition;

  @override
  int get hashCode => Object.hash(surahNumber, arabicEdition, translationEdition);
}

class AyahParams {
  final int surahNumber;
  final int ayahNumber;
  final List<String> editions;

  const AyahParams({
    required this.surahNumber,
    required this.ayahNumber,
    this.editions = const ['ar.alafasy', 'en.sahih'],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahParams &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber &&
          editions.toString() == other.editions.toString();

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, editions.hashCode);
}

class SearchParams {
  final String query;
  final String edition;
  final int limit;

  const SearchParams({
    required this.query,
    this.edition = 'en.sahih',
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          edition == other.edition &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(query, edition, limit);
}

class JuzParams {
  final int juzNumber;
  final String edition;

  const JuzParams({
    required this.juzNumber,
    this.edition = 'ar.alafasy',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JuzParams &&
          runtimeType == other.runtimeType &&
          juzNumber == other.juzNumber &&
          edition == other.edition;

  @override
  int get hashCode => Object.hash(juzNumber, edition);
}

class AyahReference {
  final int surahNumber;
  final int ayahNumber;

  const AyahReference({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahReference &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);
}

// Utility Providers
final quranStatsProvider = FutureProvider<QuranStats>((ref) async {
  try {
    final surahs = await ref.watch(surahListProvider.future);
    final bookmarkStats = await ref.watch(bookmarkStatsProvider.future);
    
    return QuranStats(
      totalSurahs: surahs.length,
      totalAyahs: surahs.fold(0, (sum, surah) => sum + surah.numberOfAyahs),
      bookmarkedAyahs: bookmarkStats.totalBookmarks,
      categoriesUsed: bookmarkStats.categoriesCount,
    );
  } catch (e) {
    throw Exception('Failed to calculate Quran stats: $e');
  }
});

class QuranStats {
  final int totalSurahs;
  final int totalAyahs;
  final int bookmarkedAyahs;
  final int categoriesUsed;

  const QuranStats({
    required this.totalSurahs,
    required this.totalAyahs,
    required this.bookmarkedAyahs,
    required this.categoriesUsed,
  });

  double get bookmarkPercentage => 
      totalAyahs > 0 ? (bookmarkedAyahs / totalAyahs) * 100 : 0.0;
}

