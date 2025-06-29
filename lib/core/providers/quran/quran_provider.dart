import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/quran/quran_api_service.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';
import 'package:islamia/data/models/quran/surah_model.dart';

final quranApiServiceProvider = Provider<QuranApiService>((ref) {
  return QuranApiService();
});

final surahListProvider = FutureProvider<List<SurahModel>>((ref) async {
  final apiService = ref.read(quranApiServiceProvider);
  try {
    return await apiService.getAllSurahs();
  } catch (e) {
    throw Exception('Failed to load Surahs: $e');
  }
});

final surahAyahsProvider = FutureProvider.family<List<AyahModel>, int>((ref, surahNumber) async {
  final apiService = ref.read(quranApiServiceProvider);
  try {
    // Get Arabic text
    final arabicAyahs = await apiService.getSurahAyahs(surahNumber, edition: 'ar.alafasy');
    
    // Get translation
    final translationAyahs = await apiService.getSurahAyahs(surahNumber, edition: 'en.sahih');
    
    // Combine Arabic and translation
    final combinedAyahs = <AyahModel>[];
    for (int i = 0; i < arabicAyahs.length; i++) {
      final arabicAyah = arabicAyahs[i];
      final translationText = i < translationAyahs.length ? translationAyahs[i].text : '';
      
      final combinedAyah = arabicAyah.copyWith(
        translations: {'en.sahih': translationText},
      );
      combinedAyahs.add(combinedAyah);
    }
    
    return combinedAyahs;
  } catch (e) {
    throw Exception('Failed to load Surah Ayahs: $e');
  }
});

final ayahWithTranslationsProvider = FutureProvider.family<AyahModel, AyahParams>((ref, params) async {
  final apiService = ref.read(quranApiServiceProvider);
  try {
    return await apiService.getAyahWithTranslations(
      params.surahNumber,
      params.ayahNumber,
      editions: params.editions,
    );
  } catch (e) {
    throw Exception('Failed to load Ayah with translations: $e');
  }
});

final searchResultsProvider = FutureProvider.family<List<AyahModel>, String>((ref, query) async {
  if (query.isEmpty || query.length < 3) return [];
  
  final apiService = ref.read(quranApiServiceProvider);
  try {
    return await apiService.searchAyahs(query);
  } catch (e) {
    throw Exception('Failed to search Ayahs: $e');
  }
});

final juzAyahsProvider = FutureProvider.family<List<AyahModel>, int>((ref, juzNumber) async {
  final apiService = ref.read(quranApiServiceProvider);
  try {
    return await apiService.getJuzAyahs(juzNumber);
  } catch (e) {
    throw Exception('Failed to load Juz Ayahs: $e');
  }
});

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
  int get hashCode => surahNumber.hashCode ^ ayahNumber.hashCode ^ editions.hashCode;
}