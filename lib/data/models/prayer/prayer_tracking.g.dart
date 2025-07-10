// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_tracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerTracking _$PrayerTrackingFromJson(Map<String, dynamic> json) =>
    PrayerTracking(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      prayerType: $enumDecode(
        _$PrayerTypeEnumMap,
        json['prayerType'],
        unknownValue: PrayerType.fajr,
      ),
      prayedAt:
          json['prayedAt'] == null
              ? null
              : DateTime.parse(json['prayedAt'] as String),
      isQaza: json['isQaza'] as bool? ?? false,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$PrayerTrackingToJson(PrayerTracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'prayerType': _$PrayerTypeEnumMap[instance.prayerType]!,
      'prayedAt': instance.prayedAt?.toIso8601String(),
      'isQaza': instance.isQaza,
      'note': instance.note,
    };

const _$PrayerTypeEnumMap = {
  PrayerType.fajr: 'fajr',
  PrayerType.sunrise: 'sunrise',
  PrayerType.dhuhr: 'dhuhr',
  PrayerType.asr: 'asr',
  PrayerType.maghrib: 'maghrib',
  PrayerType.isha: 'isha',
};

QazaCounter _$QazaCounterFromJson(Map<String, dynamic> json) => QazaCounter(
  missedPrayers:
      (json['missedPrayers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0},
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$QazaCounterToJson(QazaCounter instance) =>
    <String, dynamic>{
      'missedPrayers': instance.missedPrayers,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
