

import 'dart:math' as math;


class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? timezone;
  final double? altitude;
  final double? accuracy;
  final DateTime? timestamp;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.timezone,
    this.altitude,
    this.accuracy,
    this.timestamp,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postalCode'],
      timezone: json['timezone'],
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
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
      'postalCode': postalCode,
      'timezone': timezone,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp?.toIso8601String(),
    };
  }


double distanceTo(Location other) {
  const double earthRadius = 6371000; // in meters
  final double lat1Rad = latitude * (math.pi / 180);
  final double lat2Rad = other.latitude * (math.pi / 180);
  final double deltaLatRad = (other.latitude - latitude) * (math.pi / 180);
  final double deltaLngRad = (other.longitude - longitude) * (math.pi / 180);

  final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
      math.cos(lat1Rad) * math.cos(lat2Rad) *
      math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);

  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}




}


