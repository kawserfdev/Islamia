// import 'package:islamia/data/models/location/location.dart';

// class UserProfile {
//   final String? firstName;
//   final String? lastName;
//   final String? country;
//   final String? city;
//   final String? timeZone;
//   final Location? location;
//   final String? profileImageUrl;
//   final DateTime? dateOfBirth;
//   final String? gender;

//   const UserProfile({
//     this.firstName,
//     this.lastName,
//     this.country,
//     this.city,
//     this.timeZone,
//     this.location,
//     this.profileImageUrl,
//     this.dateOfBirth,
//     this.gender,
//   });

//   factory UserProfile.fromJson(Map<String, dynamic> json) {
//     return UserProfile(
//       firstName: json['firstName'],
//       lastName: json['lastName'],
//       country: json['country'],
//       city: json['city'],
//       timeZone: json['timeZone'],
//       location:
//           json['location'] != null ? Location.fromJson(json['location']) : null,
//       profileImageUrl: json['profileImageUrl'],
//       dateOfBirth:
//           json['dateOfBirth'] != null
//               ? DateTime.parse(json['dateOfBirth'])
//               : null,
//       gender: json['gender'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'firstName': firstName,
//       'lastName': lastName,
//       'country': country,
//       'city': city,
//       'timeZone': timeZone,
//       'location': location?.toJson(),
//       'profileImageUrl': profileImageUrl,
//       'dateOfBirth': dateOfBirth?.toIso8601String(),
//       'gender': gender,
//     };
//   }
// }



// import 'package:json_annotation/json_annotation.dart';

// part 'user_profile.g.dart';

// @JsonSerializable()
// class UserProfile {
//   final String? firstName;
//   final String? lastName;
//   final String? country;
//   final String? city;
//   final String? timeZone;
//   final DateTime? dateOfBirth;
//   final String? gender;

//   const UserProfile({
//     this.firstName,
//     this.lastName,
//     this.country,
//     this.city,
//     this.timeZone,
//     this.dateOfBirth,
//     this.gender,
//   });

//   factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
//   Map<String, dynamic> toJson() => _$UserProfileToJson(this);

//   UserProfile copyWith({
//     String? firstName,
//     String? lastName,
//     String? country,
//     String? city,
//     String? timeZone,
//     DateTime? dateOfBirth,
//     String? gender,
//   }) {
//     return UserProfile(
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       country: country ?? this.country,
//       city: city ?? this.city,
//       timeZone: timeZone ?? this.timeZone,
//       dateOfBirth: dateOfBirth ?? this.dateOfBirth,
//       gender: gender ?? this.gender,
//     );
//   }

//   String get fullName {
//     final first = firstName ?? '';
//     final last = lastName ?? '';
//     return '$first $last'.trim();
//   }
// }










import 'dart:convert';

import 'package:islamia/data/models/location/location.dart';
import 'package:islamia/data/models/user/privacy_settings.dart';
import 'package:islamia/data/models/user/user_preferences.dart';
import 'package:islamia/data/models/user/user_statistics.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? photoURL;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final Location? location;
  final String madhab;
  final String calculationMethod;
  final UserStatistics statistics;
  final UserPreferences preferences;
  final PrivacySettings privacySettings;
  final List<String> achievements;
  final AccountType accountType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final bool isVerified;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const UserProfile({
    required this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.firstName,
    this.lastName,
    this.photoURL,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.madhab = 'Shafi',
    this.calculationMethod = 'ISNA',
    required this.statistics,
    required this.preferences,
    required this.privacySettings,
    this.achievements = const [],
    this.accountType = AccountType.individual,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.isVerified = false,
    this.isActive = true,
    this.metadata = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      displayName: json['display_name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      photoURL: json['photo_url'],
      bio: json['bio'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      gender: json['gender'],
      location: json['location'] != null 
          ? Location.fromJson(json['location'] is String 
              ? jsonDecode(json['location']) 
              : json['location']) 
          : null,
      madhab: json['madhab'] ?? 'Shafi',
      calculationMethod: json['calculation_method'] ?? 'ISNA',
      statistics: UserStatistics.fromJson(json['statistics'] is String 
          ? jsonDecode(json['statistics']) 
          : json['statistics'] ?? {}),
      preferences: UserPreferences.fromJson(json['preferences'] is String 
          ? jsonDecode(json['preferences']) 
          : json['preferences'] ?? {}),
      privacySettings: PrivacySettings.fromJson(json['privacy_settings'] is String 
          ? jsonDecode(json['privacy_settings']) 
          : json['privacy_settings'] ?? {}),
      achievements: json['achievements'] is String 
          ? List<String>.from(jsonDecode(json['achievements']))
          : List<String>.from(json['achievements'] ?? []),
      accountType: AccountType.values.firstWhere(
        (e) => e.name == json['account_type'],
        orElse: () => AccountType.individual,
      ),
      createdAt: json['created_at'] is String 
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? (json['updated_at'] is String 
              ? DateTime.parse(json['updated_at'])
              : DateTime.fromMillisecondsSinceEpoch(json['updated_at']))
          : null,
      lastLoginAt: json['last_login_at'] != null 
          ? (json['last_login_at'] is String 
              ? DateTime.parse(json['last_login_at'])
              : DateTime.fromMillisecondsSinceEpoch(json['last_login_at']))
          : null,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      metadata: json['metadata'] is String 
          ? Map<String, dynamic>.from(jsonDecode(json['metadata']))
          : Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoURL,
      'bio': bio,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'location': location != null ? jsonEncode(location!.toJson()) : null,
      'madhab': madhab,
      'calculation_method': calculationMethod,
      'statistics': jsonEncode(statistics.toJson()),
      'preferences': jsonEncode(preferences.toJson()),
      'privacy_settings': jsonEncode(privacySettings.toJson()),
      'achievements': jsonEncode(achievements),
      'account_type': accountType.name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'last_login_at': lastLoginAt?.millisecondsSinceEpoch,
      'is_verified': isVerified ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'metadata': jsonEncode(metadata),
    };
  }

  // For Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoURL,
      'bio': bio,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'location': location?.toJson(),
      'madhab': madhab,
      'calculation_method': calculationMethod,
      'statistics': statistics.toJson(),
      'preferences': preferences.toJson(),
      'privacy_settings': privacySettings.toJson(),
      'achievements': achievements,
      'account_type': accountType.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_login_at': lastLoginAt,
      'is_verified': isVerified,
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'],
      email: data['email'],
      phoneNumber: data['phone_number'],
      displayName: data['display_name'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      photoURL: data['photo_url'],
      bio: data['bio'],
      dateOfBirth: data['date_of_birth']?.toDate(),
      gender: data['gender'],
      location: data['location'] != null ? Location.fromJson(data['location']) : null,
      madhab: data['madhab'] ?? 'Shafi',
      calculationMethod: data['calculation_method'] ?? 'ISNA',
      statistics: UserStatistics.fromJson(data['statistics'] ?? {}),
      preferences: UserPreferences.fromJson(data['preferences'] ?? {}),
      privacySettings: PrivacySettings.fromJson(data['privacy_settings'] ?? {}),
      achievements: List<String>.from(data['achievements'] ?? []),
      accountType: AccountType.values.firstWhere(
        (e) => e.name == data['account_type'],
        orElse: () => AccountType.individual,
      ),
      createdAt: data['created_at']?.toDate() ?? DateTime.now(),
      updatedAt: data['updated_at']?.toDate(),
      lastLoginAt: data['last_login_at']?.toDate(),
      isVerified: data['is_verified'] ?? false,
      isActive: data['is_active'] ?? true,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoURL,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    Location? location,
    String? madhab,
    String? calculationMethod,
    UserStatistics? statistics,
    UserPreferences? preferences,
    PrivacySettings? privacySettings,
    List<String>? achievements,
    AccountType? accountType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isVerified,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      madhab: madhab ?? this.madhab,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      statistics: statistics ?? this.statistics,
      preferences: preferences ?? this.preferences,
      privacySettings: privacySettings ?? this.privacySettings,
      achievements: achievements ?? this.achievements,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email?.split('@')[0] ?? 'User';
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    final name = fullName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

enum AccountType {
  individual,
  family,
  guest,
  premium,
}
