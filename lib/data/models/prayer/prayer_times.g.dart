// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerTimesModel _$PrayerTimesModelFromJson(Map<String, dynamic> json) =>
    PrayerTimesModel(
      date: DateInfo.fromJson(json['date'] as Map<String, dynamic>),
      timings: PrayerTimings.fromJson(json['timings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PrayerTimesModelToJson(PrayerTimesModel instance) =>
    <String, dynamic>{'date': instance.date, 'timings': instance.timings};

DateInfo _$DateInfoFromJson(Map<String, dynamic> json) => DateInfo(
  gregorian: GregorianDate.fromJson(json['gregorian'] as Map<String, dynamic>),
  hijri: IslamicDateInfo.fromJson(json['hijri'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DateInfoToJson(DateInfo instance) => <String, dynamic>{
  'gregorian': instance.gregorian,
  'hijri': instance.hijri,
};

GregorianDate _$GregorianDateFromJson(Map<String, dynamic> json) =>
    GregorianDate(date: json['date'] as String);

Map<String, dynamic> _$GregorianDateToJson(GregorianDate instance) =>
    <String, dynamic>{'date': instance.date};

PrayerTimings _$PrayerTimingsFromJson(Map<String, dynamic> json) =>
    PrayerTimings(
      fajr: json['Fajr'] as String,
      sunrise: json['Sunrise'] as String,
      dhuhr: json['Dhuhr'] as String,
      asr: json['Asr'] as String,
      maghrib: json['Maghrib'] as String,
      isha: json['Isha'] as String,
    );

Map<String, dynamic> _$PrayerTimingsToJson(PrayerTimings instance) =>
    <String, dynamic>{
      'Fajr': instance.fajr,
      'Sunrise': instance.sunrise,
      'Dhuhr': instance.dhuhr,
      'Asr': instance.asr,
      'Maghrib': instance.maghrib,
      'Isha': instance.isha,
    };

IslamicDateInfo _$IslamicDateInfoFromJson(Map<String, dynamic> json) =>
    IslamicDateInfo(
      date: json['date'] as String,
      day: json['day'] as String,
      month: json['month'] as String,
      year: json['year'] as String,
      islamicMonth: IslamicMonth.fromJson(
        json['islamicMonth'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$IslamicDateInfoToJson(IslamicDateInfo instance) =>
    <String, dynamic>{
      'date': instance.date,
      'day': instance.day,
      'month': instance.month,
      'year': instance.year,
      'islamicMonth': instance.islamicMonth,
    };

IslamicMonth _$IslamicMonthFromJson(Map<String, dynamic> json) =>
    IslamicMonth(en: json['en'] as String, ar: json['ar'] as String);

Map<String, dynamic> _$IslamicMonthToJson(IslamicMonth instance) =>
    <String, dynamic>{'en': instance.en, 'ar': instance.ar};
