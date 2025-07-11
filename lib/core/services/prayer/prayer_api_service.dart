import 'dart:convert';
import 'package:islamia/data/models/prayer/prayer_times_model.dart';

class PrayerApiService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  final http.Client _client;

  PrayerApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<PrayerTimesModel> getPrayerTimes({
    required double latitude,
    required double longitude,
    String method = '3', // MWL
    String madhab = '0', // Shafi
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateString = '${targetDate.day}-${targetDate.month}-${targetDate.year}';
      
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': method,
        'school': madhab,
        'format': 'json',
      };

      final uri = Uri.parse('$baseUrl/timings/$dateString')
          .replace(queryParameters: queryParams);
      
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePrayerTimes(data, latitude, longitude);
      } else {
        throw PrayerApiException('Failed to fetch prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw PrayerApiException('Error fetching prayer times: $e');
    }
  }

  Future<Map<DateTime, PrayerTimesModel>> getPrayerTimesForMonth({
    required double latitude,
    required double longitude,
    String method = '3',
    String madhab = '0',
    DateTime? month,
  }) async {
    try {
      final targetMonth = month ?? DateTime.now();
      final monthString = '${targetMonth.month}-${targetMonth.year}';
      
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': method,
        'school': madhab,
        'format': 'json',
      };

      final uri = Uri.parse('$baseUrl/calendar/$monthString')
          .replace(queryParameters: queryParams);
      
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseMonthlyPrayerTimes(data, latitude, longitude);
      } else {
        throw PrayerApiException('Failed to fetch monthly prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw PrayerApiException('Error fetching monthly prayer times: $e');
    }
  }

  Future<LocationModel> getCurrentLocation() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/currentTime'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // This is a simplified version - you'd normally use location services
        return LocationModel(
          latitude: 0.0,
          longitude: 0.0,
          city: data['data']['timezone'] ?? 'Unknown',
          country: 'Unknown',
          timezone: data['data']['timezone'] ?? 'UTC',
        );
      } else {
        throw PrayerApiException('Failed to get current location');
      }
    } catch (e) {
      throw PrayerApiException('Error getting current location: $e');
    }
  }

  Future<List<CalculationMethod>> getCalculationMethods() async {
    return [
      const CalculationMethod(
        id: '1',
        name: 'University of Islamic Sciences, Karachi',
        params: {'fajr': 18, 'isha': 18},
      ),
      const CalculationMethod(
        id: '2',
        name: 'Islamic Society of North America (ISNA)',
        params: {'fajr': 15, 'isha': 15},
      ),
      const CalculationMethod(
        id: '3',
        name: 'Muslim World League (MWL)',
        params: {'fajr': 18, 'isha': 17},
      ),
      const CalculationMethod(
        id: '4',
        name: 'Umm al-Qura, Makkah',
        params: {'fajr': 18.5, 'isha': 90}, // 90 minutes after Maghrib
      ),
      const CalculationMethod(
        id: '5',
        name: 'Egyptian General Authority of Survey',
        params: {'fajr': 19.5, 'isha': 17.5},
      ),
    ];
  }

  PrayerTimesModel _parsePrayerTimes(
    Map<String, dynamic> data,
    double latitude,
    double longitude,
  ) {
    final timings = data['data']['timings'];
    final date = data['data']['date'];
    final meta = data['data']['meta'];
    
    final baseDate = DateTime.parse('${date['gregorian']['year']}-${date['gregorian']['month']['number'].toString().padLeft(2, '0')}-${date['gregorian']['day'].toString().padLeft(2, '0')}');
    
    return PrayerTimesModel(
      id: '${latitude}_${longitude}_${baseDate.millisecondsSinceEpoch}',
      date: baseDate,
      location: LocationModel(
        latitude: latitude,
        longitude: longitude,
        city: meta['timezone'] ?? 'Unknown',
        country: 'Unknown',
        timezone: meta['timezone'] ?? 'UTC',
      ),
      fajr: _parseTime(timings['Fajr'], baseDate),
      sunrise: _parseTime(timings['Sunrise'], baseDate),
      dhuhr: _parseTime(timings['Dhuhr'], baseDate),
      asr: _parseTime(timings['Asr'], baseDate),
      maghrib: _parseTime(timings['Maghrib'], baseDate),
      isha: _parseTime(timings['Isha'], baseDate),
      midnight: _parseTime(timings['Midnight'], baseDate),
      calculationMethod: meta['method']['name'] ?? 'Unknown',
      madhab: meta['school'] ?? 'Shafi',
      timezone: meta['timezone'] ?? 'UTC',
    );
  }

  Map<DateTime, PrayerTimesModel> _parseMonthlyPrayerTimes(
    Map<String, dynamic> data,
    double latitude,
    double longitude,
  ) {
    final result = <DateTime, PrayerTimesModel>{};
    final monthData = data['data'] as List;
    
    for (final dayData in monthData) {
      final prayerTimes = _parsePrayerTimes({'data': dayData}, latitude, longitude);
      result[prayerTimes.date] = prayerTimes;
    }
    
    return result;
  }

  DateTime _parseTime(String timeString, DateTime baseDate) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }

  void dispose() {
    _client.close();
  }
}

class PrayerApiException implements Exception {
  final String message;
  
  PrayerApiException(this.message);
  
  @override
  String toString() => 'PrayerApiException: $message';
}

class CalculationMethod {
  final String id;
  final String name;
  final Map<String, dynamic> params;

  const CalculationMethod({
    required this.id,
    required this.name,
    required this.params,
  });
}