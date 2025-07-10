// import 'dart:math' as math;

// import 'package:islamia/data/models/qibla/qibla_model.dart';

// class QiblaCalculationService {
//   static const double _earthRadius = 6371000; // Earth radius in meters
//   static const KaabaInfo _kaaba = KaabaInfo();

//   /// Calculate Qibla direction using spherical trigonometry
//   static double calculateQiblaDirection(double latitude, double longitude) {
//     final lat1 = _degreeToRadian(latitude);
//     final lon1 = _degreeToRadian(longitude);
//     final lat2 = _degreeToRadian(_kaaba.latitude);
//     final lon2 = _degreeToRadian(_kaaba.longitude);

//     final deltaLon = lon2 - lon1;

//     final y = math.sin(deltaLon) * math.cos(lat2);
//     final x = math.cos(lat1) * math.sin(lat2) - 
//               math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

//     var bearing = math.atan2(y, x);
//     bearing = _radianToDegree(bearing);
//     bearing = (bearing + 360) % 360; // Normalize to 0-360

//     return bearing;
//   }

//   /// Calculate distance to Kaaba using Haversine formula
//   static double calculateDistanceToKaaba(double latitude, double longitude) {
//     final lat1 = _degreeToRadian(latitude);
//     final lon1 = _degreeToRadian(longitude);
//     final lat2 = _degreeToRadian(_kaaba.latitude);
//     final lon2 = _degreeToRadian(_kaaba.longitude);

//     final deltaLat = lat2 - lat1;
//     final deltaLon = lon2 - lon1;

//     final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
//               math.cos(lat1) * math.cos(lat2) *
//               math.sin(deltaLon / 2) * math.sin(deltaLon / 2);

//     final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     return _earthRadius * c;
//   }

//   /// Calculate both direction and distance
//   static QiblaData calculateQiblaData(LocationInfo location) {
//     final direction = calculateQiblaDirection(location.latitude, location.longitude);
//     final distance = calculateDistanceToKaaba(location.latitude, location.longitude);

//     return QiblaData(
//       direction: direction,
//       distance: distance,
//       location: location,
//       kaaba: _kaaba,
//       calculatedAt: DateTime.now(),
//       source: QiblaSource.calculation,
//     );
//   }

//   /// Apply magnetic declination correction
//   static double applyMagneticDeclination(
//     double magneticHeading,
//     double latitude,
//     double longitude,
//   ) {
//     // Simplified magnetic declination calculation
//     // In a production app, you'd use more accurate IGRF model or API
//     final declination = _calculateMagneticDeclination(latitude, longitude);
//     return (magneticHeading + declination + 360) % 360;
//   }

//   /// Simplified magnetic declination calculation
//   static double _calculateMagneticDeclination(double latitude, double longitude) {
//     // This is a very simplified approximation
//     // For accurate results, use NOAA's magnetic field calculator or similar service
//     final latRadians = _degreeToRadian(latitude);
//     final lonRadians = _degreeToRadian(longitude);
    
//     // Simplified formula - replace with proper IGRF calculation in production
//     final declination = math.sin(latRadians) * math.cos(lonRadians) * 10;
//     return declination;
//   }

//   /// Smooth compass readings to reduce jitter
//   static double smoothCompassReading(
//     List<double> readings,
//     {double alpha = 0.2}
//   ) {
//     if (readings.isEmpty) return 0.0;
//     if (readings.length == 1) return readings.first;

//     // Exponential moving average
//     double smoothed = readings.first;
//     for (int i = 1; i < readings.length; i++) {
//       final current = readings[i];
//       final previous = smoothed;
      
//       // Handle circular nature of angles
//       double delta = current - previous;
//       if (delta > 180) delta -= 360;
//       if (delta < -180) delta += 360;
      
//       smoothed = previous + alpha * delta;
//       smoothed = (smoothed + 360) % 360;
//     }

//     return smoothed;
//   }

//   /// Calculate compass accuracy based on multiple readings
//   static double calculateAccuracy(List<double> readings) {
//     if (readings.length < 2) return 0.0;

//     double sum = 0.0;
//     double sumOfSquares = 0.0;
//     final count = readings.length;

//     for (final reading in readings) {
//       sum += reading;
//       sumOfSquares += reading * reading;
//     }

//     final mean = sum / count;
//     final variance = (sumOfSquares / count) - (mean * mean);
//     return math.sqrt(variance);
//   }

//   /// Convert degrees to radians
//   static double _degreeToRadian(double degree) {
//     return degree * (math.pi / 180);
//   }

//   /// Convert radians to degrees
//   static double _radianToDegree(double radian) {
//     return radian * (180 / math.pi);
//   }

//   /// Check if two angles are within tolerance
//   static bool isWithinTolerance(double angle1, double angle2, double tolerance) {
//     double diff = (angle1 - angle2).abs();
//     if (diff > 180) diff = 360 - diff;
//     return diff <= tolerance;
//   }

//   /// Get cardinal direction name from angle
//   static String getCardinalDirection(double angle) {
//     const directions = [
//       'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
//       'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
//     ];
    
//     final index = ((angle + 11.25) / 22.5).floor() % 16;
//     return directions[index];
//   }

//   /// Format angle for display
//   static String formatAngle(double angle, {int decimals = 1}) {
//     return '${angle.toStringAsFixed(decimals)}°';
//   }

//   /// Format distance for display
//   static String formatDistance(double meters, {bool useMetric = true}) {
//     if (useMetric) {
//       if (meters >= 1000) {
//         return '${(meters / 1000).toStringAsFixed(1)} km';
//       } else {
//         return '${meters.toStringAsFixed(0)} m';
//       }
//     } else {
//       final miles = meters * 0.000621371;
//       if (miles >= 1) {
//         return '${miles.toStringAsFixed(1)} mi';
//       } else {
//         final feet = meters * 3.28084;
//         return '${feet.toStringAsFixed(0)} ft';
//       }
//     }
//   }
// }