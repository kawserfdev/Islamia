// import 'package:islamia/data/models/location/location.dart';
// import 'package:islamia/data/models/mosque/mosque_prayer_info.dart';

// class Mosque {
//   final String id;
//   final String name;
//   final String? arabicName;
//   final Location location;
//   final String address;
//   final String? phone;
//   final String? website;
//   final String? email;
//   final double? rating;
//   final int? reviewCount;
//   final List<String> images;
//   final MosqueType type;
//   final List<MosqueFacility> facilities;
//   final MosquePrayerInfo prayerInfo;
//   final bool isVerified;
//   final DateTime? lastUpdated;
//   final double? distanceFromUser;

//   const Mosque({
//     required this.id,
//     required this.name,
//     this.arabicName,
//     required this.location,
//     required this.address,
//     this.phone,
//     this.website,
//     this.email,
//     this.rating,
//     this.reviewCount,
//     this.images = const [],
//     this.type = MosqueType.mosque,
//     this.facilities = const [],
//     required this.prayerInfo,
//     this.isVerified = false,
//     this.lastUpdated,
//     this.distanceFromUser,
//   });

//   factory Mosque.fromJson(Map<String, dynamic> json) {
//     return Mosque(
//       id: json['id'],
//       name: json['name'],
//       arabicName: json['arabicName'],
//       location: Location.fromJson(json['location']),
//       address: json['address'],
//       phone: json['phone'],
//       website: json['website'],
//       email: json['email'],
//       rating: json['rating']?.toDouble(),
//       reviewCount: json['reviewCount'],
//       images: List<String>.from(json['images'] ?? []),
//       type: MosqueType.values.firstWhere(
//         (e) => e.name == json['type'], 
//         orElse: () => MosqueType.mosque,
//       ),
//       facilities: (json['facilities'] as List?)
//           ?.map((e) => MosqueFacility.values.firstWhere((f) => f.name == e))
//           .toList() ?? [],
//       prayerInfo: MosquePrayerInfo.fromJson(json['prayerInfo'] ?? {}),
//       isVerified: json['isVerified'] ?? false,
//       lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
//       distanceFromUser: json['distanceFromUser']?.toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'arabicName': arabicName,
//       'location': location.toJson(),
//       'address': address,
//       'phone': phone,
//       'website': website,
//       'email': email,
//       'rating': rating,
//       'reviewCount': reviewCount,
//       'images': images,
//       'type': type.name,
//       'facilities': facilities.map((e) => e.name).toList(),
//       'prayerInfo': prayerInfo.toJson(),
//       'isVerified': isVerified,
//       'lastUpdated': lastUpdated?.toIso8601String(),
//       'distanceFromUser': distanceFromUser,
//     };
//   }

//   String get formattedDistance {
//     if (distanceFromUser == null) return '';
//     if (distanceFromUser! < 1000) {
//       return '${distanceFromUser!.toStringAsFixed(0)} m';
//     } else {
//       return '${(distanceFromUser! / 1000).toStringAsFixed(1)} km';
//     }
//   }
// }






import 'dart:convert';
import 'dart:math' as math;
import 'package:islamia/data/models/location/location.dart';
import 'package:islamia/data/models/mosque/mosque_facilities.dart';
import 'package:islamia/data/models/mosque/mosque_prayer_times.dart';
import 'package:islamia/data/models/mosque/mosque_review.dart';

class MosqueModel {
  final String id;
  final String name;
  final String address;
  final Location location;
  final String? phoneNumber;
  final String? website;
  final String? email;
  final List<String> photos;
  final MosqueFacilities facilities;
  final MosquePrayerTimes? prayerTimes;
  final double rating;
  final int reviewCount;
  final List<MosqueReview> reviews;
  final bool isVerified;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? description;
  final MosqueType type;
  final int? capacity;
  final String? imam;
  final List<String> languages;
  final MosqueStatus status;
  final Map<String, dynamic> metadata;

  const MosqueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.phoneNumber,
    this.website,
    this.email,
    this.photos = const [],
    required this.facilities,
    this.prayerTimes,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [],
    this.isVerified = false,
    this.isFavorite = false,
    required this.createdAt,
    this.updatedAt,
    this.description,
    this.type = MosqueType.mosque,
    this.capacity,
    this.imam,
    this.languages = const [],
    this.status = MosqueStatus.active,
    this.metadata = const {},
  });

  factory MosqueModel.fromJson(Map<String, dynamic> json) {
    return MosqueModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      location: Location.fromJson(json['location'] is String 
          ? jsonDecode(json['location']) 
          : json['location'] ?? {}),
      phoneNumber: json['phone_number'],
      website: json['website'],
      email: json['email'],
      photos: json['photos'] is String 
          ? List<String>.from(jsonDecode(json['photos']))
          : List<String>.from(json['photos'] ?? []),
      facilities: MosqueFacilities.fromJson(json['facilities'] is String 
          ? jsonDecode(json['facilities']) 
          : json['facilities'] ?? {}),
      prayerTimes: json['prayer_times'] != null 
          ? MosquePrayerTimes.fromJson(json['prayer_times'] is String 
              ? jsonDecode(json['prayer_times']) 
              : json['prayer_times']) 
          : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      reviews: json['reviews'] is String 
          ? (jsonDecode(json['reviews']) as List)
              .map((e) => MosqueReview.fromJson(e))
              .toList()
          : (json['reviews'] as List?)
              ?.map((e) => MosqueReview.fromJson(e))
              .toList() ?? [],
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == true,
      createdAt: json['created_at'] is String 
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(json['created_at'] ?? 0),
      updatedAt: json['updated_at'] != null 
          ? (json['updated_at'] is String 
              ? DateTime.parse(json['updated_at'])
              : DateTime.fromMillisecondsSinceEpoch(json['updated_at']))
          : null,
      description: json['description'],
      type: MosqueType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MosqueType.mosque,
      ),
      capacity: json['capacity'],
      imam: json['imam'],
      languages: json['languages'] is String 
          ? List<String>.from(jsonDecode(json['languages']))
          : List<String>.from(json['languages'] ?? []),
      status: MosqueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MosqueStatus.active,
      ),
      metadata: json['metadata'] is String 
          ? Map<String, dynamic>.from(jsonDecode(json['metadata']))
          : Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': jsonEncode(location.toJson()),
      'phone_number': phoneNumber,
      'website': website,
      'email': email,
      'photos': jsonEncode(photos),
      'facilities': jsonEncode(facilities.toJson()),
      'prayer_times': prayerTimes != null ? jsonEncode(prayerTimes!.toJson()) : null,
      'rating': rating,
      'review_count': reviewCount,
      'reviews': jsonEncode(reviews.map((e) => e.toJson()).toList()),
      'is_verified': isVerified ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'description': description,
      'type': type.name,
      'capacity': capacity,
      'imam': imam,
      'languages': jsonEncode(languages),
      'status': status.name,
      'metadata': jsonEncode(metadata),
    };
  }

  Map<String, dynamic> toSQLiteMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'location_address': location.address,
      'location_city': location.city,
      'location_country': location.country,
      'phone_number': phoneNumber,
      'website': website,
      'email': email,
      'photos': jsonEncode(photos),
      'facilities': jsonEncode(facilities.toJson()),
      'prayer_times': prayerTimes != null ? jsonEncode(prayerTimes!.toJson()) : null,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'description': description,
      'type': type.name,
      'capacity': capacity,
      'imam': imam,
      'languages': jsonEncode(languages),
      'status': status.name,
      'metadata': jsonEncode(metadata),
    };
  }

  factory MosqueModel.fromSQLiteMap(Map<String, dynamic> map) {
    return MosqueModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      location: Location(
        latitude: map['latitude'],
        longitude: map['longitude'],
        address: map['location_address'],
        city: map['location_city'],
        country: map['location_country'],
      ),
      phoneNumber: map['phone_number'],
      website: map['website'],
      email: map['email'],
      photos: map['photos'] != null 
          ? List<String>.from(jsonDecode(map['photos']))
          : [],
      facilities: MosqueFacilities.fromJson(
        map['facilities'] != null 
            ? jsonDecode(map['facilities'])
            : {}
      ),
      prayerTimes: map['prayer_times'] != null 
          ? MosquePrayerTimes.fromJson(jsonDecode(map['prayer_times']))
          : null,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['review_count'] ?? 0,
      reviews: [], // Reviews loaded separately
      isVerified: map['is_verified'] == 1,
      isFavorite: map['is_favorite'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
      description: map['description'],
      type: MosqueType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MosqueType.mosque,
      ),
      capacity: map['capacity'],
      imam: map['imam'],
      languages: map['languages'] != null 
          ? List<String>.from(jsonDecode(map['languages']))
          : [],
      status: MosqueStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MosqueStatus.active,
      ),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(jsonDecode(map['metadata']))
          : {},
    );
  }

  MosqueModel copyWith({
    String? id,
    String? name,
    String? address,
    Location? location,
    String? phoneNumber,
    String? website,
    String? email,
    List<String>? photos,
    MosqueFacilities? facilities,
    MosquePrayerTimes? prayerTimes,
    double? rating,
    int? reviewCount,
    List<MosqueReview>? reviews,
    bool? isVerified,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    MosqueType? type,
    int? capacity,
    String? imam,
    List<String>? languages,
    MosqueStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return MosqueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      email: email ?? this.email,
      photos: photos ?? this.photos,
      facilities: facilities ?? this.facilities,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      reviews: reviews ?? this.reviews,
      isVerified: isVerified ?? this.isVerified,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      imam: imam ?? this.imam,
      languages: languages ?? this.languages,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  // Calculate distance from current location
  double distanceFrom(Location currentLocation) {
    return _calculateDistance(currentLocation, location);
  }

  // Get formatted distance
  String getFormattedDistance(Location currentLocation) {
    return _formatDistance(distanceFrom(currentLocation));
  }

  // Helper methods for distance calculation
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

  static double _degreesToRadians(double degrees) => degrees * (math.pi / 180);

  static String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 100) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }
}

enum MosqueType {
  mosque,
  jameMasjid,
  islamicCenter,
  musalla,
  madrasa,
}

enum MosqueStatus {
  active,
  inactive,
  underConstruction,
  temporarilyClosed,
}