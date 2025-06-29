import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/quran_provider.dart';
import 'package:islamia/core/services/quran/audio_service.dart';
import 'package:islamia/data/models/quran/reciter_model.dart';

final audioServiceProvider =
    StateNotifierProvider<AudioService, AudioPlayerState>((ref) {
      return AudioService();
    });

final reciterListProvider = FutureProvider<List<ReciterModel>>((ref) async {
  final apiService = ref.read(quranApiServiceProvider);
  try {
    return await apiService.getReciters();
  } catch (e) {
    // Return default reciters if API fails
    return [
      const ReciterModel(
        identifier: 'ar.alafasy',
        name: 'مشاري العفاسي',
        englishName: 'Mishary Alafasy',
        format: 'mp3',
        type: 'audio', language: '',
      ),
      const ReciterModel(
        identifier: 'ar.husary',
        name: 'محمود خليل الحصري',
        englishName: 'Mahmoud Khalil Al-Husary',
        format: 'mp3',
        type: 'audio', language: '',
      ),
      const ReciterModel(
        identifier: 'ar.sudais',
        name: 'عبد الرحمن السديس',
        englishName: 'Abdul Rahman Al-Sudais',
        format: 'mp3',
        type: 'audio', language: '',
      ),
    ];
  }
});

final selectedReciterProvider = StateProvider<String>((ref) {
  return 'ar.alafasy'; // Default reciter
});
