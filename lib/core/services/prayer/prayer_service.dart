import 'dart:convert';

import 'package:islamia/core/constants/app_constants.dart';
import 'package:islamia/core/services/api/api_service.dart';
import 'package:islamia/data/models/prayer/prayer_times.dart';

class PrayerService {
  final ApiService _apiService = ApiService();

  Future<PrayerTimesModel> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
    String method = ApiConstants.defaultCalculationMethod,
    String madhab = ApiConstants.defaultMadhab,
  }) async {
    final now = DateTime.now();
    final url =
        '${ApiConstants.aladhanBaseUrl}/calendar/${now.year}/${now.month}'
        '?latitude=$latitude&longitude=$longitude&method=$method&school=$madhab';

    final response = await _apiService.get(url);
    final data = response['data'] as List;

    // Get today's prayer times
    final today = data.firstWhere(
      (day) => DateTime.parse(day['date']['gregorian']['date']).day == now.day,
    );

    print("PrayerTimesModel: ${jsonEncode(today)}");

    return PrayerTimesModel.fromJson(today);
  }

  Future<IslamicDateInfo> getIslamicDate() async {
    final now = DateTime.now();
    final url =
        '${ApiConstants.aladhanBaseUrl}${ApiConstants.islamicDateEndpoint}'
        '/${now.day}-${now.month}-${now.year}';

    final response = await _apiService.get(url);
    return IslamicDateInfo.fromJson(response['data']);
  }
}
