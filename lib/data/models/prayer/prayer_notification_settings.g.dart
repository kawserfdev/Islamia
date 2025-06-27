// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerNotificationSettings _$PrayerNotificationSettingsFromJson(
  Map<String, dynamic> json,
) => PrayerNotificationSettings(
  fajrEnabled: json['fajrEnabled'] as bool? ?? true,
  dhuhrEnabled: json['dhuhrEnabled'] as bool? ?? true,
  asrEnabled: json['asrEnabled'] as bool? ?? true,
  maghribEnabled: json['maghribEnabled'] as bool? ?? true,
  ishaEnabled: json['ishaEnabled'] as bool? ?? true,
  sunriseEnabled: json['sunriseEnabled'] as bool? ?? false,
  reminderMinutesBefore: (json['reminderMinutesBefore'] as num?)?.toInt() ?? 0,
  vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
  adhanEnabled: json['adhanEnabled'] as bool? ?? true,
  volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
);

Map<String, dynamic> _$PrayerNotificationSettingsToJson(
  PrayerNotificationSettings instance,
) => <String, dynamic>{
  'fajrEnabled': instance.fajrEnabled,
  'dhuhrEnabled': instance.dhuhrEnabled,
  'asrEnabled': instance.asrEnabled,
  'maghribEnabled': instance.maghribEnabled,
  'ishaEnabled': instance.ishaEnabled,
  'sunriseEnabled': instance.sunriseEnabled,
  'reminderMinutesBefore': instance.reminderMinutesBefore,
  'vibrationEnabled': instance.vibrationEnabled,
  'adhanEnabled': instance.adhanEnabled,
  'volume': instance.volume,
};
