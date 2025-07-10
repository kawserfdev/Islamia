// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerTimesModel _$PrayerTimesModelFromJson(Map<String, dynamic> json) =>
    PrayerTimesModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      fajr: DateTime.parse(json['fajr'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      dhuhr: DateTime.parse(json['dhuhr'] as String),
      asr: DateTime.parse(json['asr'] as String),
      maghrib: DateTime.parse(json['maghrib'] as String),
      isha: DateTime.parse(json['isha'] as String),
      midnight:
          json['midnight'] == null
              ? null
              : DateTime.parse(json['midnight'] as String),
      tahajjud:
          json['tahajjud'] == null
              ? null
              : DateTime.parse(json['tahajjud'] as String),
      calculationMethod: json['calculationMethod'] as String,
      madhab: json['madhab'] as String,
      timezone: json['timezone'] as String,
      adjustments:
          (json['adjustments'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$PrayerTimesModelToJson(PrayerTimesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'location': instance.location,
      'fajr': instance.fajr.toIso8601String(),
      'sunrise': instance.sunrise.toIso8601String(),
      'dhuhr': instance.dhuhr.toIso8601String(),
      'asr': instance.asr.toIso8601String(),
      'maghrib': instance.maghrib.toIso8601String(),
      'isha': instance.isha.toIso8601String(),
      'midnight': instance.midnight?.toIso8601String(),
      'tahajjud': instance.tahajjud?.toIso8601String(),
      'calculationMethod': instance.calculationMethod,
      'madhab': instance.madhab,
      'timezone': instance.timezone,
      'adjustments': instance.adjustments,
    };

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      country: json['country'] as String,
      timezone: json['timezone'] as String,
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'city': instance.city,
      'country': instance.country,
      'timezone': instance.timezone,
    };

PrayerSettings _$PrayerSettingsFromJson(Map<String, dynamic> json) =>
    PrayerSettings(
      calculationMethod: json['calculationMethod'] as String? ?? 'MWL',
      madhab: json['madhab'] as String? ?? 'Shafi',
      adjustments:
          (json['adjustments'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      prayerNotifications:
          (json['prayerNotifications'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {
            'fajr': true,
            'dhuhr': true,
            'asr': true,
            'maghrib': true,
            'isha': true,
            'tahajjud': false,
          },
      adhanEnabled: json['adhanEnabled'] as bool? ?? true,
      adhanSound: json['adhanSound'] as String? ?? 'default',
      adhanVolume: (json['adhanVolume'] as num?)?.toDouble() ?? 0.8,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      reminderMinutes: (json['reminderMinutes'] as num?)?.toInt() ?? 0,
      locationAutoUpdate: json['locationAutoUpdate'] as bool? ?? true,
      manualLocation:
          json['manualLocation'] == null
              ? null
              : LocationModel.fromJson(
                json['manualLocation'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$PrayerSettingsToJson(PrayerSettings instance) =>
    <String, dynamic>{
      'calculationMethod': instance.calculationMethod,
      'madhab': instance.madhab,
      'adjustments': instance.adjustments,
      'notificationsEnabled': instance.notificationsEnabled,
      'prayerNotifications': instance.prayerNotifications,
      'adhanEnabled': instance.adhanEnabled,
      'adhanSound': instance.adhanSound,
      'adhanVolume': instance.adhanVolume,
      'vibrationEnabled': instance.vibrationEnabled,
      'reminderMinutes': instance.reminderMinutes,
      'locationAutoUpdate': instance.locationAutoUpdate,
      'manualLocation': instance.manualLocation,
    };
