import 'package:islamia/data/models/location/location.dart';
import 'package:islamia/data/models/mosque/mosque_prayer_info.dart';

class Mosque {
  final String id;
  final String name;
  final String? arabicName;
  final Location location;
  final String address;
  final String? phone;
  final String? website;
  final String? email;
  final double? rating;
  final int? reviewCount;
  final List<String> images;
  final MosqueType type;
  final List<MosqueFacility> facilities;
  final MosquePrayerInfo prayerInfo;
  final bool isVerified;
  final DateTime? lastUpdated;
  final double? distanceFromUser;

  const Mosque({
    required this.id,
    required this.name,
    this.arabicName,
    required this.location,
    required this.address,
    this.phone,
    this.website,
    this.email,
    this.rating,
    this.reviewCount,
    this.images = const [],
    this.type = MosqueType.mosque,
    this.facilities = const [],
    required this.prayerInfo,
    this.isVerified = false,
    this.lastUpdated,
    this.distanceFromUser,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabicName'],
      location: Location.fromJson(json['location']),
      address: json['address'],
      phone: json['phone'],
      website: json['website'],
      email: json['email'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      images: List<String>.from(json['images'] ?? []),
      type: MosqueType.values.firstWhere(
        (e) => e.name == json['type'], 
        orElse: () => MosqueType.mosque,
      ),
      facilities: (json['facilities'] as List?)
          ?.map((e) => MosqueFacility.values.firstWhere((f) => f.name == e))
          .toList() ?? [],
      prayerInfo: MosquePrayerInfo.fromJson(json['prayerInfo'] ?? {}),
      isVerified: json['isVerified'] ?? false,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      distanceFromUser: json['distanceFromUser']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'location': location.toJson(),
      'address': address,
      'phone': phone,
      'website': website,
      'email': email,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'type': type.name,
      'facilities': facilities.map((e) => e.name).toList(),
      'prayerInfo': prayerInfo.toJson(),
      'isVerified': isVerified,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'distanceFromUser': distanceFromUser,
    };
  }

  String get formattedDistance {
    if (distanceFromUser == null) return '';
    if (distanceFromUser! < 1000) {
      return '${distanceFromUser!.toStringAsFixed(0)} m';
    } else {
      return '${(distanceFromUser! / 1000).toStringAsFixed(1)} km';
    }
  }
}