import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:islamia/data/models/prayer/prayer_times_model.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<LocationModel> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled.');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      // Get place information
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        final placemark = placemarks.first;
        
        return LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          city: placemark.locality ?? placemark.subAdministrativeArea ?? 'Unknown',
          country: placemark.country ?? 'Unknown',
          timezone: DateTime.now().timeZoneName,
        );
      } catch (e) {
        // If geocoding fails, return location with coordinates only
        return LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          city: 'Unknown',
          country: 'Unknown',
          timezone: DateTime.now().timeZoneName,
        );
      }
    } catch (e) {
      throw LocationException('Failed to get current location: $e');
    }
  }

  Future<LocationModel> getLocationFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final placemark = placemarks.first;
      
      return LocationModel(
        latitude: latitude,
        longitude: longitude,
        city: placemark.locality ?? placemark.subAdministrativeArea ?? 'Unknown',
        country: placemark.country ?? 'Unknown',
        timezone: DateTime.now().timeZoneName,
      );
    } catch (e) {
      return LocationModel(
        latitude: latitude,
        longitude: longitude,
        city: 'Unknown',
        country: 'Unknown',
        timezone: DateTime.now().timeZoneName,
      );
    }
  }

  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      final locations = await locationFromAddress(query);
      final results = <LocationModel>[];
      
      for (final location in locations.take(5)) {
        final locationModel = await getLocationFromCoordinates(
          location.latitude,
          location.longitude,
        );
        results.add(locationModel);
      }
      
      return results;
    } catch (e) {
      throw LocationException('Failed to search locations: $e');
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      ),
    );
  }

  Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Future<double> calculateQiblaDirection(
    double latitude,
    double longitude,
  ) async {
    // Kaaba coordinates
    const double kaabaLatitude = 21.4225;
    const double kaabaLongitude = 39.8262;
    
    return Geolocator.bearingBetween(
      latitude,
      longitude,
      kaabaLatitude,
      kaabaLongitude,
    );
  }
}

class LocationException implements Exception {
  final String message;
  
  LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}