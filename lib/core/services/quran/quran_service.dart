import 'dart:math';
import 'package:islamia/core/constants/app_constants.dart';
import 'package:islamia/core/services/api/api_service.dart';
import 'package:islamia/data/models/daily/daily_verse_model.dart';
import 'package:islamia/data/models/quran/ayah_audio_model.dart';

class QuranService {
  final ApiService _apiService = ApiService();

  Future<DailyVerseModel> getDailyVerse() async {
    // Generate random verse number (1-6236 total verses in Quran)
    final random = Random();
    final verseNumber = random.nextInt(6236) + 1;

    final arabicUrl =
        '${ApiConstants.quranBaseUrl}${ApiConstants.randomVerseEndpoint}/$verseNumber';
    final translationUrl =
        '${ApiConstants.quranBaseUrl}${ApiConstants.randomVerseEndpoint}/$verseNumber/en.asad';

    final arabicResponse = await _apiService.get(arabicUrl);
    final translationResponse = await _apiService.get(translationUrl);

    final arabicData = arabicResponse['data'];
    final translationData = translationResponse['data'];

    return DailyVerseModel(
      number: arabicData['number'],
      text: arabicData['text'],
      translation: translationData['text'],
      surah: SurahInfo.fromJson(arabicData['surah']),
      numberInSurah: arabicData['numberInSurah'],
    );
  }
}

class AyahAudioService {
  final ApiService _apiService = ApiService();

  Future<AyahAudioModel> getAudioAyah(String url) async {
    final audioAyahResponse = await _apiService.get(url);

    final ayahData = audioAyahResponse['data'];
    return AyahAudioModel.fromJson(ayahData);
  }
}
