// import 'package:islamia/data/models/location/location.dart';

// class QiblaInfo {
//   final double bearing;
//   final double distance;
//   final Location userLocation;
//   final Location meccarLocation;
//   final DateTime calculatedAt;
//   final double magneticDeclination;
//   final QiblaAccuracy accuracy;

//   static const Location meccaLocation = Location(
//     latitude: 21.4225,
//     longitude: 39.8262,
//     city: 'Mecca',
//     country: 'Saudi Arabia',
//   );

//   const QiblaInfo({
//     required this.bearing,
//     required this.distance,
//     required this.userLocation,
//     this.meccarLocation = meccaLocation,
//     required this.calculatedAt,
//     this.magneticDeclination = 0.0,
//     this.accuracy = QiblaAccuracy.medium,
//   });

//   factory QiblaInfo.fromJson(Map<String, dynamic> json) {
//     return QiblaInfo(
//       bearing: json['bearing'].toDouble(),
//       distance: json['distance'].toDouble(),
//       userLocation: Location.fromJson(json['userLocation']),
//       meccarLocation: json['meccarLocation'] != null 
//           ? Location.fromJson(json['meccarLocation']) 
//           : meccaLocation,
//       calculatedAt: DateTime.parse(json['calculatedAt']),
//       magneticDeclination: (json['magneticDeclination'] ?? 0.0).toDouble(),
//       accuracy: QiblaAccuracy.values.firstWhere(
//         (e) => e.name == json['accuracy'], 
//         orElse: () => QiblaAccuracy.medium,
//       ),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'bearing': bearing,
//       'distance': distance,
//       'userLocation': userLocation.toJson(),
//       'meccarLocation': meccarLocation.toJson(),
//       'calculatedAt': calculatedAt.toIso8601String(),
//       'magneticDeclination': magneticDeclination,
//       'accuracy': accuracy.name,
//     };
//   }

//   String get formattedDistance {
//     if (distance < 1000) {
//       return '${distance.toStringAsFixed(0)} m';
//     } else {
//       return '${(distance / 1000).toStringAsFixed(1)} km';
//     }
//   }

//   String get formattedBearing {
//     return '${bearing.toStringAsFixed(1)}°';
//   }

//   String get compassDirection {
//     const List<String> directions = [
//       'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
//       'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
//     ];
    
//     final int index = ((bearing + 11.25) / 22.5).floor() % 16;
//     return directions[index];
//   }
// }

// enum QiblaAccuracy {
//   high,
//   medium,
//   low;

//   String get displayName {
//     switch (this) {
//       case QiblaAccuracy.high:
//         return 'High Accuracy';
//       case QiblaAccuracy.medium:
//         return 'Medium Accuracy';
//       case QiblaAccuracy.low:
//         return 'Low Accuracy';
//     }
//   }
// }
