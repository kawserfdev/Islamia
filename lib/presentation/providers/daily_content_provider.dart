import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/hadith/hadith_service.dart';
import 'package:islamia/core/services/quran/quran_service.dart';
import 'package:islamia/data/models/daily/daily_hadith_model.dart';
import 'package:islamia/data/models/daily/daily_verse_model.dart';

final quranServiceProvider = Provider<QuranService>((ref) {
  return QuranService();
});

final hadithServiceProvider = Provider<HadithService>((ref) {
  return HadithService();
});

final dailyVerseProvider = FutureProvider<DailyVerseModel>((ref) async {
  final service = ref.read(quranServiceProvider);
  return await service.getDailyVerse();
});

final dailyHadithProvider = FutureProvider<DailyHadithModel>((ref) async {
  final service = ref.read(hadithServiceProvider);
  return await service.getDailyHadith();
});