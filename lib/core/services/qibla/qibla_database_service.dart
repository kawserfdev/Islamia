// import 'dart:convert';
// import 'package:islamia/data/models/qibla/qibla_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class QiblaDatabaseService {
//   static const String _qiblaDataKey = 'qibla_data';
//   static const String _qiblaSettingsKey = 'qibla_settings';
//   static const String _calibrationDataKey = 'calibration_data';

//   Future<void> cacheQiblaData(QiblaData qiblaData) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = jsonEncode(qiblaData.toJson());
//       await prefs.setString(_qiblaDataKey, jsonString);
//     } catch (e) {
//       throw QiblaDatabaseException('Failed to cache Qibla data: $e');
//     }
//   }

//   Future<QiblaData?> getCachedQiblaData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = prefs.getString(_qiblaDataKey);
      
//       if (jsonString != null) {
//         final jsonData = jsonDecode(jsonString);
//         return QiblaData.fromJson(jsonData);
//       }
      
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> saveQiblaSettings(QiblaSettings settings) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = jsonEncode(settings.toJson());
//       await prefs.setString(_qiblaSettingsKey, jsonString);
//     } catch (e) {
//       throw QiblaDatabaseException('Failed to save Qibla settings: $e');
//     }
//   }

//   Future<QiblaSettings> getQiblaSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = prefs.getString(_qiblaSettingsKey);
      
//       if (jsonString != null) {
//         final jsonData = jsonDecode(jsonString);
//         return QiblaSettings.fromJson(jsonData);
//       }
      
//       return const QiblaSettings();
//     } catch (e) {
//       return const QiblaSettings();
//     }
//   }

//   Future<void> saveCalibrationData(Map<String, dynamic> calibrationData) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = jsonEncode(calibrationData);
//       await prefs.setString(_calibrationDataKey, jsonString);
//     } catch (e) {
//       throw QiblaDatabaseException('Failed to save calibration data: $e');
//     }
//   }

//   Future<Map<String, dynamic>?> getCalibrationData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = prefs.getString(_calibrationDataKey);
      
//       if (jsonString != null) {
//         return Map<String, dynamic>.from(jsonDecode(jsonString));
//       }
      
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_qiblaDataKey);
//       await prefs.remove(_calibrationDataKey);
//     } catch (e) {
//       throw QiblaDatabaseException('Failed to clear cache: $e');
//     }
//   }
// }

// class QiblaDatabaseException implements Exception {
//   final String message;
  
//   QiblaDatabaseException(this.message);
  
//   @override
//   String toString() => 'QiblaDatabaseException: $message';
// }