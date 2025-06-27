import 'package:islamia/data/models/prayer/prayer_notification_settings.dart';
import 'package:islamia/data/models/user/user_profile.dart';

// class UserModel {
//   final String? id;
//   final String? email;
//   final String? phoneNumber;
//   final String? displayName;
//   final String? photoURL;
//   final DateTime? createdAt;
//   final DateTime? lastLoginAt;
//   final UserPreferences preferences;
//   final UserProfile profile;

//   const UserModel({
//     this.id,
//     this.email,
//     this.phoneNumber,
//     this.displayName,
//     this.photoURL,
//     this.createdAt,
//     this.lastLoginAt,
//     required this.preferences,
//     required this.profile,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       email: json['email'],
//       phoneNumber: json['phoneNumber'],
//       displayName: json['displayName'],
//       photoURL: json['photoURL'],
//       createdAt:
//           json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
//       lastLoginAt:
//           json['lastLoginAt'] != null
//               ? DateTime.parse(json['lastLoginAt'])
//               : null,
//       preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
//       profile: UserProfile.fromJson(json['profile'] ?? {}),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'email': email,
//       'phoneNumber': phoneNumber,
//       'displayName': displayName,
//       'photoURL': photoURL,
//       'createdAt': createdAt?.toIso8601String(),
//       'lastLoginAt': lastLoginAt?.toIso8601String(),
//       'preferences': preferences.toJson(),
//       'profile': profile.toJson(),
//     };
//   }

//   UserModel copyWith({
//     String? id,
//     String? email,
//     String? phoneNumber,
//     String? displayName,
//     String? photoURL,
//     DateTime? createdAt,
//     DateTime? lastLoginAt,
//     UserPreferences? preferences,
//     UserProfile? profile,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       email: email ?? this.email,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       displayName: displayName ?? this.displayName,
//       photoURL: photoURL ?? this.photoURL,
//       createdAt: createdAt ?? this.createdAt,
//       lastLoginAt: lastLoginAt ?? this.lastLoginAt,
//       preferences: preferences ?? this.preferences,
//       profile: profile ?? this.profile,
//     );
//   }
// }


import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';



@JsonSerializable()
class UserModel {
  final String? id;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final UserPreferences preferences;
  final UserProfile profile;

  const UserModel({
    this.id,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    required this.preferences,
    required this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    UserProfile? profile,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      profile: profile ?? this.profile,
    );
  }

  bool get isGuest => id == null;
  String get displayText => displayName ?? email ?? phoneNumber ?? 'Guest User';
}

// class UserPreferences {
//   final String language;
//   final bool isDarkMode;
//   final bool notificationsEnabled;
//   final PrayerNotificationSettings prayerNotifications;
//   final String calculationMethod;
//   final String madhab;
//   final String qiblaCalculationMethod;
//   final List<String> enabledTranslations;
//   final String defaultReciter;
//   final double audioPlaybackSpeed;
//   final bool autoPlayNext;
//   final bool showArabicText;
//   final bool showTranslation;
//   final bool showTransliteration;
//   final double fontSize;
//   final String fontFamily;

//   const UserPreferences({
//     this.language = 'en',
//     this.isDarkMode = false,
//     this.notificationsEnabled = true,
//     required this.prayerNotifications,
//     this.calculationMethod = 'ISNA',
//     this.madhab = 'Shafi',
//     this.qiblaCalculationMethod = 'standard',
//     this.enabledTranslations = const ['en'],
//     this.defaultReciter = 'ar.alafasy',
//     this.audioPlaybackSpeed = 1.0,
//     this.autoPlayNext = true,
//     this.showArabicText = true,
//     this.showTranslation = true,
//     this.showTransliteration = false,
//     this.fontSize = 16.0,
//     this.fontFamily = 'Noto Naskh Arabic',
//   });

//   factory UserPreferences.fromJson(Map<String, dynamic> json) {
//     return UserPreferences(
//       language: json['language'] ?? 'en',
//       isDarkMode: json['isDarkMode'] ?? false,
//       notificationsEnabled: json['notificationsEnabled'] ?? true,
//       prayerNotifications: PrayerNotificationSettings.fromJson(
//         json['prayerNotifications'] ?? {},
//       ),
//       calculationMethod: json['calculationMethod'] ?? 'ISNA',
//       madhab: json['madhab'] ?? 'Shafi',
//       qiblaCalculationMethod: json['qiblaCalculationMethod'] ?? 'standard',
//       enabledTranslations: List<String>.from(
//         json['enabledTranslations'] ?? ['en'],
//       ),
//       defaultReciter: json['defaultReciter'] ?? 'ar.alafasy',
//       audioPlaybackSpeed: (json['audioPlaybackSpeed'] ?? 1.0).toDouble(),
//       autoPlayNext: json['autoPlayNext'] ?? true,
//       showArabicText: json['showArabicText'] ?? true,
//       showTranslation: json['showTranslation'] ?? true,
//       showTransliteration: json['showTransliteration'] ?? false,
//       fontSize: (json['fontSize'] ?? 16.0).toDouble(),
//       fontFamily: json['fontFamily'] ?? 'Noto Naskh Arabic',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'language': language,
//       'isDarkMode': isDarkMode,
//       'notificationsEnabled': notificationsEnabled,
//       'prayerNotifications': prayerNotifications.toJson(),
//       'calculationMethod': calculationMethod,
//       'madhab': madhab,
//       'qiblaCalculationMethod': qiblaCalculationMethod,
//       'enabledTranslations': enabledTranslations,
//       'defaultReciter': defaultReciter,
//       'audioPlaybackSpeed': audioPlaybackSpeed,
//       'autoPlayNext': autoPlayNext,
//       'showArabicText': showArabicText,
//       'showTranslation': showTranslation,
//       'showTransliteration': showTransliteration,
//       'fontSize': fontSize,
//       'fontFamily': fontFamily,
//     };
//   }
// }



@JsonSerializable()
class UserPreferences {
  final String language;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String calculationMethod;
  final String madhab;
  final double fontSize;
  final String fontFamily;
  final List<String> enabledTranslations;
  final String defaultReciter;
  final PrayerNotificationSettings prayerNotifications;

  const UserPreferences({
    this.language = 'en',
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.calculationMethod = 'ISNA',
    this.madhab = 'Shafi',
    this.fontSize = 16.0,
    this.fontFamily = 'Noto Naskh Arabic',
    this.enabledTranslations = const ['en'],
    this.defaultReciter = 'ar.alafasy',
    required this.prayerNotifications,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    String? language,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? calculationMethod,
    String? madhab,
    double? fontSize,
    String? fontFamily,
    List<String>? enabledTranslations,
    String? defaultReciter,
    PrayerNotificationSettings? prayerNotifications,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      enabledTranslations: enabledTranslations ?? this.enabledTranslations,
      defaultReciter: defaultReciter ?? this.defaultReciter,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
    );
  }
}