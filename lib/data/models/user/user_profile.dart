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



import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? country;
  final String? city;
  final String? timeZone;
  final DateTime? dateOfBirth;
  final String? gender;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.country,
    this.city,
    this.timeZone,
    this.dateOfBirth,
    this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? country,
    String? city,
    String? timeZone,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      city: city ?? this.city,
      timeZone: timeZone ?? this.timeZone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }
}
