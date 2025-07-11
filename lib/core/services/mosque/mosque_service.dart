import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MosqueService {
  static const String _googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  final http.Client _httpClient;
  final MosqueDatabase _database;

  MosqueService({
    http.Client? httpClient,
    MosqueDatabase? database,
  }) : _httpClient = httpClient ?? http.Client(),
       _database = database ?? MosqueDatabase();

  // Search nearby mosques (online + offline)
  Future<MosqueSearchResult> searchNearbyMosques({
    required Location location,
    double radius = 10000, // 10km in meters
    String? query,
    MosqueSearchFilters? filters,
    MosqueSearchSort sortBy = MosqueSearchSort.distance,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Try online search first
      final onlineResults = await _searchOnlineMosques(
        location: location,
        radius: radius,
        query: query,
        limit: limit,
      );

      // Cache results locally
      if (onlineResults.isNotEmpty) {
        await _database.insertMosques(onlineResults);
      }

      // Get results from local database with filters
      final localResults = await _database.searchNearbyMosques(
        location: location,
        radiusKm: radius / 1000,
        query: query,
        filters: filters,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
      );

      // Save search history
      if (query != null && query.isNotEmpty) {
        await _database.saveSearchHistory(
          query: query,
          location: location,
          radius: radius / 1000,
          filters: filters,
        );
      }

      return MosqueSearchResult(
        mosques: localResults,
        totalCount: localResults.length,
        hasMore: localResults.length >= limit,
      );

    } catch (e) {
      // Fallback to offline search only
      final localResults = await _database.searchNearbyMosques(
        location: location,
        radiusKm: radius / 1000,
        query: query,
        filters: filters,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
      );

      return MosqueSearchResult(
        mosques: localResults,
        totalCount: localResults.length,
        hasMore: false,
      );
    }
  }

  // Search mosques online using Google Places API
  Future<List<MosqueModel>> _searchOnlineMosques({
    required Location location,
    double radius = 10000,
    String? query,
    int limit = 20,
  }) async {
    final params = {
      'location': '${location.latitude},${location.longitude}',
      'radius': radius.toString(),
      'type': 'mosque',
      'key': _googlePlacesApiKey,
    };

    if (query != null && query.isNotEmpty) {
      params['keyword'] = query;
    }

    final uri = Uri.parse('$_baseUrl/nearbysearch/json')
        .replace(queryParameters: params);

    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK') {
        final List<dynamic> results = data['results'];
        final mosques = <MosqueModel>[];

        for (final result in results) {
          final mosque = await _convertPlaceToMosque(result, location);
          if (mosque != null) {
            mosques.add(mosque);
          }
        }

        return mosques;
      } else {
        throw Exception('Places API error: ${data['status']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  // Get mosque details with additional information
  Future<MosqueModel?> getMosqueDetails(String mosqueId) async {
    // First try to get from local database
    var mosque = await _database.getMosqueById(mosqueId);
    
    if (mosque != null) {
      return mosque;
    }

    // If not found locally and we have a Google Place ID, fetch from API
    try {
      final params = {
        'place_id': mosqueId,
        'fields': 'name,formatted_address,geometry,formatted_phone_number,'
                 'website,rating,user_ratings_total,photos,opening_hours,'
                 'reviews,types,vicinity',
        'key': _googlePlacesApiKey,
      };

      final uri = Uri.parse('$_baseUrl/details/json')
          .replace(queryParameters: params);

      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          mosque = await _convertPlaceToMosque(result, null);
          
          if (mosque != null) {
            await _database.insertOrUpdateMosque(mosque);
            return mosque;
          }
        }
      }
    } catch (e) {
      print('Error getting mosque details: $e');
    }
    
    return null;
  }

  // Convert Google Places result to MosqueModel
  Future<MosqueModel?> _convertPlaceToMosque(
    Map<String, dynamic> place,
    Location? searchLocation,
  ) async {
    try {
      final geometry = place['geometry'];
      final location = geometry['location'];
      
      final mosqueLocation = Location(
        latitude: location['lat'].toDouble(),
        longitude: location['lng'].toDouble(),
        address: place['vicinity'] ?? place['formatted_address'],
      );

      // Extract photos
      final List<String> photos = [];
      if (place['photos'] != null) {
        for (final photo in place['photos']) {
          final photoUrl = _buildPhotoUrl(photo['photo_reference']);
          photos.add(photoUrl);
        }
      }

      // Create basic facilities (can be enhanced later)
      final facilities = MosqueFacilities(
        hasWuduArea: true,
        hasRestroom: true,
        // Other facilities would need to be determined from reviews/descriptions
      );

      return MosqueModel(
        id: place['place_id'] ?? _generateId(),
        name: place['name'] ?? 'Unknown Mosque',
        address: place['vicinity'] ?? place['formatted_address'] ?? '',
        location: mosqueLocation,
        phoneNumber: place['formatted_phone_number'],
        website: place['website'],
        photos: photos,
        facilities: facilities,
        rating: (place['rating'] ?? 0.0).toDouble(),
        reviewCount: place['user_ratings_total'] ?? 0,
        isVerified: place['business_status'] == 'OPERATIONAL',
        createdAt: DateTime.now(),
        type: _determineMosqueType(place),
      );
    } catch (e) {
      print('Error converting place to mosque: $e');
      return null;
    }
  }

  // Build photo URL from Google Places photo reference
  String _buildPhotoUrl(String photoReference) {
    return '$_baseUrl/photo?maxwidth=400&photoreference=$photoReference&key=$_googlePlacesApiKey';
  }

  // Determine mosque type from place data
  MosqueType _determineMosqueType(Map<String, dynamic> place) {
    final name = (place['name'] as String? ?? '').toLowerCase();
    final types = List<String>.from(place['types'] ?? []);
    
    if (name.contains('islamic center') || types.contains('establishment')) {
      return MosqueType.islamicCenter;
    } else if (name.contains('jame') || name.contains('jamia')) {
      return MosqueType.jameMasjid;
    } else if (name.contains('musalla')) {
      return MosqueType.musalla;
    } else if (name.contains('madrasa') || name.contains('madrasah')) {
      return MosqueType.madrasa;
    }
    
    return MosqueType.mosque;
  }

  // Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Add mosque to favorites
  Future<void> addToFavorites(String mosqueId, String userId) async {
    await _database.addToFavorites(mosqueId, userId);
  }

  // Remove mosque from favorites
  Future<void> removeFromFavorites(String mosqueId, String userId) async {
    await _database.removeFromFavorites(mosqueId, userId);
  }

  // Get favorite mosques
  Future<List<MosqueModel>> getFavoriteMosques(String userId) async {
    return await _database.getFavoriteMosques(userId);
  }

  // Check if mosque is favorite
  Future<bool> isFavorite(String mosqueId, String userId) async {
    return await _database.isFavorite(mosqueId, userId);
  }

  // Add new mosque (user contribution)
  Future<String> addMosque(MosqueModel mosque) async {
    final newMosque = mosque.copyWith(
      id: mosque.id.isEmpty ? _generateId() : mosque.id,
      createdAt: DateTime.now(),
      isVerified: false, // User-added mosques need verification
    );
    
    await _database.insertOrUpdateMosque(newMosque);
    return newMosque.id;
  }

  // Update mosque
  Future<void> updateMosque(MosqueModel mosque) async {
    final updatedMosque = mosque.copyWith(updatedAt: DateTime.now());
    await _database.insertOrUpdateMosque(updatedMosque);
  }

  // Add review
  Future<void> addReview(MosqueReview review) async {
    await _database.insertReview(review);
  }

  // Get reviews for mosque
  Future<List<MosqueReview>> getReviews(String mosqueId) async {
    return await _database.getReviewsByMosqueId(mosqueId);
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    await _database.deleteReview(reviewId);
  }

  // Get search history
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    return await _database.getSearchHistory();
  }

  // Get current location
  Future<Location> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
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

  // Clear all cached data
  Future<void> clearCache() async {
    await _database.clearAllData();
  }

  // Dispose resources
  void dispose() {
    _httpClient.close();
  }
}