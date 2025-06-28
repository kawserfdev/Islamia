import 'package:json_annotation/json_annotation.dart';

part 'prayer_times.g.dart';
@JsonSerializable()
class PrayerTimesModel {
  final String date;
  final PrayerTimings timings;
  final IslamicDateInfo hijri;

  const PrayerTimesModel({
    required this.date,
    required this.timings,
    required this.hijri,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrayerTimesModelToJson(this);
}

@JsonSerializable()
class PrayerTimings {
  @JsonKey(name: 'Fajr')
  final String fajr;
  @JsonKey(name: 'Sunrise')
  final String sunrise;
  @JsonKey(name: 'Dhuhr')
  final String dhuhr;
  @JsonKey(name: 'Asr')
  final String asr;
  @JsonKey(name: 'Maghrib')
  final String maghrib;
  @JsonKey(name: 'Isha')
  final String isha;

  const PrayerTimings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimingsFromJson(json);

  Map<String, dynamic> toJson() => _$PrayerTimingsToJson(this);

  List<PrayerTime> get prayersList => [
    PrayerTime('Fajr', fajr),
    PrayerTime('Sunrise', sunrise),
    PrayerTime('Dhuhr', dhuhr),
    PrayerTime('Asr', asr),
    PrayerTime('Maghrib', maghrib),
    PrayerTime('Isha', isha),
  ];
}

class PrayerTime {
  final String name;
  final String time;

  const PrayerTime(this.name, this.time);
}

@JsonSerializable()
class IslamicDateInfo {
  final String date;
  final String day;
  final String month;
  final String year;
  final IslamicMonth islamicMonth;

  const IslamicDateInfo({
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.islamicMonth,
  });

  factory IslamicDateInfo.fromJson(Map<String, dynamic> json) =>
      _$IslamicDateInfoFromJson(json);

  Map<String, dynamic> toJson() => _$IslamicDateInfoToJson(this);
}

@JsonSerializable()
class IslamicMonth {
  final String en;
  final String ar;

  const IslamicMonth({
    required this.en,
    required this.ar,
  });

  factory IslamicMonth.fromJson(Map<String, dynamic> json) =>
      _$IslamicMonthFromJson(json);

  Map<String, dynamic> toJson() => _$IslamicMonthToJson(this);
}