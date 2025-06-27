// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String?,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  photoURL: json['photoURL'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  lastLoginAt:
      json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
  preferences: UserPreferences.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
  profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'phoneNumber': instance.phoneNumber,
  'photoURL': instance.photoURL,
  'isEmailVerified': instance.isEmailVerified,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'preferences': instance.preferences,
  'profile': instance.profile,
};

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      language: json['language'] as String? ?? 'en',
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      calculationMethod: json['calculationMethod'] as String? ?? 'ISNA',
      madhab: json['madhab'] as String? ?? 'Shafi',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontFamily: json['fontFamily'] as String? ?? 'Noto Naskh Arabic',
      enabledTranslations:
          (json['enabledTranslations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['en'],
      defaultReciter: json['defaultReciter'] as String? ?? 'ar.alafasy',
      prayerNotifications: PrayerNotificationSettings.fromJson(
        json['prayerNotifications'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'language': instance.language,
      'isDarkMode': instance.isDarkMode,
      'notificationsEnabled': instance.notificationsEnabled,
      'calculationMethod': instance.calculationMethod,
      'madhab': instance.madhab,
      'fontSize': instance.fontSize,
      'fontFamily': instance.fontFamily,
      'enabledTranslations': instance.enabledTranslations,
      'defaultReciter': instance.defaultReciter,
      'prayerNotifications': instance.prayerNotifications,
    };
