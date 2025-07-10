// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:islamia/data/models/qibla/qibla_model.dart';

// class QiblaApiService {
//   static const String baseUrl = 'https://api.aladhan.com/v1';
//   final http.Client _client;

//   QiblaApiService({http.Client? client}) : _client = client ?? http.Client();

//   Future<QiblaData> getQiblaDirection({
//     required double latitude,
//     required double longitude,
//     String? city,
//     String? country,
//   }) async {
//     try {
//       final queryParams = {
//         'latitude': latitude.toString(),
//         'longitude': longitude.toString(),
//       };

//       final uri = Uri.parse('$baseUrl/qibla').replace(queryParameters: queryParams);
//       final response = await _client.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return _parseQiblaResponse(data, latitude, longitude, city, country);
//       } else {
//         throw QiblaApiException('Failed to fetch Qibla direction: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw QiblaApiException('Error fetching Qibla direction: $e');
//     }
//   }

//   QiblaData _parseQiblaResponse(
//     Map<String, dynamic> data,
//     double latitude,
//     double longitude,
//     String? city,
//     String? country,
//   ) {
//     final qiblaData = data['data'];
//     final direction = (qiblaData['direction'] as num).toDouble();
//     final distance = (qiblaData['distance'] as num).toDouble() * 1000; // Convert km to meters

//     final location = LocationInfo(
//       latitude: latitude,
//       longitude: longitude,
//       city: city ?? 'Unknown',
//       country: country ?? 'Unknown',
//       accuracy: 0.0,
//     );

//     return QiblaData(
//       direction: direction,
//       distance: distance,
//       location: location,
//       kaaba: const KaabaInfo(),
//       calculatedAt: DateTime.now(),
//       source: QiblaSource.api,
//     );
//   }

//   void dispose() {
//     _client.close();
//   }
// }

// class QiblaApiException implements Exception {
//   final String message;
  
//   QiblaApiException(this.message);
  
//   @override
//   String toString() => 'QiblaApiException: $message';
// }