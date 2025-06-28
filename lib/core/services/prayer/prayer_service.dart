import 'dart:convert';

import 'package:intl/intl.dart';
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
    print("Next Prayer Time Url: $url");

    final response = await _apiService.get(url);
    final data = response['data'] as List;
    print("Next Prayer Times: ${data}");
    print("Raw response: ${jsonEncode(response)}");

    // Parse '01-06-2025' to DateTime
    try {
      final formatter = DateFormat('dd-MM-yyyy');

      final today = data.firstWhere((day) {
        final gregorian = day['date']['gregorian'] as Map<String, dynamic>;
        final dateString = gregorian['date'] as String;
        final date = formatter.parse(dateString);
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }, orElse: () => throw Exception("No matching prayer time for today"));
      print("Today JSON: ${jsonEncode(today)}");
      print("Today: $today");
      print("PrayerTimesModel: ${jsonEncode(today)}");

      return PrayerTimesModel.fromJson(today as Map<String, dynamic>);
    } catch (e) {
      print("Error parsing today's prayer: $e");
      rethrow;
    }
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
