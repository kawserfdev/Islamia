import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islamia/data/models/qibla/qibla_model.dart';

class QiblaService {
  static const Location _kaaba = Location.kaaba;

  // Calculate Qibla direction using Great Circle method
  static QiblaModel calculateQiblaDirection(Location userLocation) {
    final double userLat = _degreesToRadians(userLocation.latitude);
    final double userLng = _degreesToRadians(userLocation.longitude);
    final double kaabaLat = _degreesToRadians(_kaaba.latitude);
    final double kaabaLng = _degreesToRadians(_kaaba.longitude);

    final double deltaLng = kaabaLng - userLng;

    // Calculate bearing using Great Circle formula
    final double y = math.sin(deltaLng) * math.cos(kaabaLat);
    final double x = math.cos(userLat) * math.sin(kaabaLat) - 
                     math.sin(userLat) * math.cos(kaabaLat) * math.cos(deltaLng);

    double bearing = math.atan2(y, x);
    bearing = _radiansToDegrees(bearing);
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    // Calculate distance using Haversine formula
    final double distance = _calculateDistance(userLocation, _kaaba);

    return QiblaModel(
      direction: bearing,
      distance: distance,
      userLocation: userLocation,
      meccaLocation: _kaaba,
      calculatedAt: DateTime.now(),
      calculationMethod: 'great_circle',
      isAccurate: true,
      accuracy: 1.0,
    );
  }

  // Calculate distance between two locations using Haversine formula
  static double _calculateDistance(Location from, Location to) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1Rad = _degreesToRadians(from.latitude);
    final double lat2Rad = _degreesToRadians(to.latitude);
    final double deltaLatRad = _degreesToRadians(to.latitude - from.latitude);
    final double deltaLngRad = _degreesToRadians(to.longitude - from.longitude);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Get device compass heading stream
  static Stream<double>? getCompassStream() {
    return FlutterCompass.events?.map((event) => event.heading ?? 0.0);
  }

  // Check if compass is available
  static Future<bool> isCompassAvailable() async {
    return await FlutterCompass.events != null;
  }

  // Get current location
  static Future<Location> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );
  }

  // Utility functions
  static double _degreesToRadians(double degrees) => degrees * (math.pi / 180);
  static double _radiansToDegrees(double radians) => radians * (180 / math.pi);

  // Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 100) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  // Format direction for display
  static String formatDirection(double degrees) {
    final directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}

// Custom exceptions
class LocationServiceDisabledException implements Exception {
  final String message = 'Location services are disabled.';
}

class LocationPermissionDeniedException implements Exception {
  final String message = 'Location permission denied.';
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message = 'Location permission permanently denied.';
}