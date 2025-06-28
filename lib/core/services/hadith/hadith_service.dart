import 'package:islamia/core/services/api/api_service.dart';
import 'package:islamia/data/models/daily/daily_hadith_model.dart';


class HadithService {
  final ApiService _apiService = ApiService();

  Future<DailyHadithModel> getDailyHadith() async {
    // Note: Using a placeholder implementation as hadith APIs vary
    // You can integrate with your preferred hadith API
    const url = 'https://api.hadith.sutanlab.id/books/bukhari/1';

    try {
      final response = await _apiService.get(url);
      final data = response['data'];
      
      return DailyHadithModel(
        arab: data['arab'] ?? '',
        english: data['english'] ?? '',
        source: 'Sahih Bukhari',
        grade: 'Sahih',
      );
    } catch (e) {
      // Fallback hadith
      return const DailyHadithModel(
        arab: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
        english: 'Actions are but by intention.',
        source: 'Sahih Bukhari',
        grade: 'Sahih',
      );
    }
  }
}