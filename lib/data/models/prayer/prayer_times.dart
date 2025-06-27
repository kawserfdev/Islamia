import 'package:islamia/data/models/location/location.dart';
import 'package:islamia/data/models/prayer/prayer_log.dart';

class PrayerTimes {
  final String id;
  final DateTime date;
  final Location location;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String calculationMethod;
  final String madhab;
  final String timezone;
  final Map<String, int> adjustments;

  const PrayerTimes({
    required this.id,
    required this.date,
    required this.location,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.calculationMethod,
    required this.madhab,
    required this.timezone,
    this.adjustments = const {},
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      id: json['id'],
      date: DateTime.parse(json['date']),
      location: Location.fromJson(json['location']),
      fajr: DateTime.parse(json['fajr']),
      sunrise: DateTime.parse(json['sunrise']),
      dhuhr: DateTime.parse(json['dhuhr']),
      asr: DateTime.parse(json['asr']),
      maghrib: DateTime.parse(json['maghrib']),
      isha: DateTime.parse(json['isha']),
      calculationMethod: json['calculationMethod'],
      madhab: json['madhab'],
      timezone: json['timezone'],
      adjustments: Map<String, int>.from(json['adjustments'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'location': location.toJson(),
      'fajr': fajr.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'calculationMethod': calculationMethod,
      'madhab': madhab,
      'timezone': timezone,
      'adjustments': adjustments,
    };
  }

  DateTime getPrayerTime(PrayerType prayer) {
    switch (prayer) {
      case PrayerType.fajr:
        return fajr;
      case PrayerType.sunrise:
        return sunrise;
      case PrayerType.dhuhr:
        return dhuhr;
      case PrayerType.asr:
        return asr;
      case PrayerType.maghrib:
        return maghrib;
      case PrayerType.isha:
        return isha;
    }
  }

  PrayerType? getNextPrayer() {
    final now = DateTime.now();
    final prayers = [
      (PrayerType.fajr, fajr),
      (PrayerType.sunrise, sunrise),
      (PrayerType.dhuhr, dhuhr),
      (PrayerType.asr, asr),
      (PrayerType.maghrib, maghrib),
      (PrayerType.isha, isha),
    ];

    for (final (prayer, time) in prayers) {
      if (now.isBefore(time)) {
        return prayer;
      }
    }
    return null; // All prayers have passed for today
  }
}