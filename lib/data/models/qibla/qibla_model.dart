class QiblaModel {
  final double direction;
  final double distance;
  final Location userLocation;
  final Location meccaLocation;
  final DateTime calculatedAt;
  final String calculationMethod;
  final bool isAccurate;
  final double accuracy;

  const QiblaModel({
    required this.direction,
    required this.distance,
    required this.userLocation,
    required this.meccaLocation,
    required this.calculatedAt,
    this.calculationMethod = 'great_circle',
    this.isAccurate = true,
    this.accuracy = 0.0,
  });

  factory QiblaModel.fromJson(Map<String, dynamic> json) {
    return QiblaModel(
      direction: json['direction'].toDouble(),
      distance: json['distance'].toDouble(),
      userLocation: Location.fromJson(json['userLocation']),
      meccaLocation: Location.fromJson(json['meccaLocation']),
      calculatedAt: DateTime.parse(json['calculatedAt']),
      calculationMethod: json['calculationMethod'] ?? 'great_circle',
      isAccurate: json['isAccurate'] ?? true,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'distance': distance,
      'userLocation': userLocation.toJson(),
      'meccaLocation': meccaLocation.toJson(),
      'calculatedAt': calculatedAt.toIso8601String(),
      'calculationMethod': calculationMethod,
      'isAccurate': isAccurate,
      'accuracy': accuracy,
    };
  }

  QiblaModel copyWith({
    double? direction,
    double? distance,
    Location? userLocation,
    Location? meccaLocation,
    DateTime? calculatedAt,
    String? calculationMethod,
    bool? isAccurate,
    double? accuracy,
  }) {
    return QiblaModel(
      direction: direction ?? this.direction,
      distance: distance ?? this.distance,
      userLocation: userLocation ?? this.userLocation,
      meccaLocation: meccaLocation ?? this.meccaLocation,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      isAccurate: isAccurate ?? this.isAccurate,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

// models/location.dart
class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;
  final DateTime? timestamp;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.timestamp,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  // Kaaba location constant
  static const Location kaaba = Location(
    latitude: 21.4225,
    longitude: 39.8262,
    address: 'Masjid al-Haram, Mecca',
    city: 'Mecca',
    country: 'Saudi Arabia',
  );
}

enum CompassState {
  loading,
  ready,
  calibrating,
  error,
  noPermission,
  noSensor,
}