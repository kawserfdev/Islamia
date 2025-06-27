import 'package:islamia/data/models/common/time_range.dart';
import 'package:islamia/data/models/prayer/prayer_log.dart';

// class PrayerNotificationSettings {
//   final bool fajrEnabled;
//   final bool dhuhrEnabled;
//   final bool asrEnabled;
//   final bool maghribEnabled;
//   final bool ishaEnabled;
//   final bool sunriseEnabled;
//   final int reminderMinutesBefore;
//   final bool vibrationEnabled;
//   final String notificationSound;
//   final bool adhanEnabled;
//   final String adhanReciter;
//   final double volume;
//   final bool silentModeEnabled;
//   final TimeRange? silentModeRange;

//   const PrayerNotificationSettings({
//     this.fajrEnabled = true,
//     this.dhuhrEnabled = true,
//     this.asrEnabled = true,
//     this.maghribEnabled = true,
//     this.ishaEnabled = true,
//     this.sunriseEnabled = false,
//     this.reminderMinutesBefore = 0,
//     this.vibrationEnabled = true,
//     this.notificationSound = 'default',
//     this.adhanEnabled = true,
//     this.adhanReciter = 'default',
//     this.volume = 0.8,
//     this.silentModeEnabled = false,
//     this.silentModeRange,
//   });

//   factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
//     return PrayerNotificationSettings(
//       fajrEnabled: json['fajrEnabled'] ?? true,
//       dhuhrEnabled: json['dhuhrEnabled'] ?? true,
//       asrEnabled: json['asrEnabled'] ?? true,
//       maghribEnabled: json['maghribEnabled'] ?? true,
//       ishaEnabled: json['ishaEnabled'] ?? true,
//       sunriseEnabled: json['sunriseEnabled'] ?? false,
//       reminderMinutesBefore: json['reminderMinutesBefore'] ?? 0,
//       vibrationEnabled: json['vibrationEnabled'] ?? true,
//       notificationSound: json['notificationSound'] ?? 'default',
//       adhanEnabled: json['adhanEnabled'] ?? true,
//       adhanReciter: json['adhanReciter'] ?? 'default',
//       volume: (json['volume'] ?? 0.8).toDouble(),
//       silentModeEnabled: json['silentModeEnabled'] ?? false,
//       silentModeRange: json['silentModeRange'] != null 
//           ? TimeRange.fromJson(json['silentModeRange']) 
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'fajrEnabled': fajrEnabled,
//       'dhuhrEnabled': dhuhrEnabled,
//       'asrEnabled': asrEnabled,
//       'maghribEnabled': maghribEnabled,
//       'ishaEnabled': ishaEnabled,
//       'sunriseEnabled': sunriseEnabled,
//       'reminderMinutesBefore': reminderMinutesBefore,
//       'vibrationEnabled': vibrationEnabled,
//       'notificationSound': notificationSound,
//       'adhanEnabled': adhanEnabled,
//       'adhanReciter': adhanReciter,
//       'volume': volume,
//       'silentModeEnabled': silentModeEnabled,
//       'silentModeRange': silentModeRange?.toJson(),
//     };
//   }

//   bool isPrayerEnabled(PrayerType prayer) {
//     switch (prayer) {
//       case PrayerType.fajr:
//         return fajrEnabled;
//       case PrayerType.sunrise:
//         return sunriseEnabled;
//       case PrayerType.dhuhr:
//         return dhuhrEnabled;
//       case PrayerType.asr:
//         return asrEnabled;
//       case PrayerType.maghrib:
//         return maghribEnabled;
//       case PrayerType.isha:
//         return ishaEnabled;
//     }
//   }
// }


import 'package:json_annotation/json_annotation.dart';
part 'prayer_notification_settings.g.dart';




@JsonSerializable()
class PrayerNotificationSettings {
  final bool fajrEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;
  final bool sunriseEnabled;
  final int reminderMinutesBefore;
  final bool vibrationEnabled;
  final bool adhanEnabled;
  final double volume;

  const PrayerNotificationSettings({
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
    this.sunriseEnabled = false,
    this.reminderMinutesBefore = 0,
    this.vibrationEnabled = true,
    this.adhanEnabled = true,
    this.volume = 0.8,
  });

  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) => 
      _$PrayerNotificationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerNotificationSettingsToJson(this);

  PrayerNotificationSettings copyWith({
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
    bool? sunriseEnabled,
    int? reminderMinutesBefore,
    bool? vibrationEnabled,
    bool? adhanEnabled,
    double? volume,
  }) {
    return PrayerNotificationSettings(
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
      sunriseEnabled: sunriseEnabled ?? this.sunriseEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      volume: volume ?? this.volume,
    );
  }
    bool isPrayerEnabled(PrayerType prayer) {
    switch (prayer) {
      case PrayerType.fajr:
        return fajrEnabled;
      case PrayerType.sunrise:
        return sunriseEnabled;
      case PrayerType.dhuhr:
        return dhuhrEnabled;
      case PrayerType.asr:
        return asrEnabled;
      case PrayerType.maghrib:
        return maghribEnabled;
      case PrayerType.isha:
        return ishaEnabled;
    }
  }
}
