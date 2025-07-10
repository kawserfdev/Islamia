import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prayer_times_model.g.dart';

@JsonSerializable()
class PrayerTimesModel {
  final String id;
  final DateTime date;
  final LocationModel location;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime? midnight;
  final DateTime? tahajjud;
  final String calculationMethod;
  final String madhab;
  final String timezone;
  final Map<String, int> adjustments;

  const PrayerTimesModel({
    required this.id,
    required this.date,
    required this.location,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.midnight,
    this.tahajjud,
    required this.calculationMethod,
    required this.madhab,
    required this.timezone,
    this.adjustments = const {},
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) => _$PrayerTimesModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerTimesModelToJson(this);

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
      case PrayerType.tahajjud:
        return tahajjud ?? _calculateTahajjudTime();
    }
  }

  DateTime _calculateTahajjudTime() {
    // Last third of the night (between Isha and Fajr)
    final nightDuration = fajr.add(const Duration(days: 1)).difference(isha);
    final lastThirdStart = isha.add(Duration(milliseconds: (nightDuration.inMilliseconds * 2 / 3).round()));
    return lastThirdStart;
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
    return null; // All prayers passed for today
  }

  Duration? getTimeToNextPrayer() {
    final nextPrayer = getNextPrayer();
    if (nextPrayer == null) return null;
    
    final nextPrayerTime = getPrayerTime(nextPrayer);
    return nextPrayerTime.difference(DateTime.now());
  }

  PrayerType? getCurrentPrayer() {
    final now = DateTime.now();
    
    if (now.isAfter(isha) || now.isBefore(fajr)) return null;
    if (now.isAfter(maghrib)) return PrayerType.maghrib;
    if (now.isAfter(asr)) return PrayerType.asr;
    if (now.isAfter(dhuhr)) return PrayerType.dhuhr;
    if (now.isAfter(sunrise)) return null; // Between sunrise and dhuhr
    if (now.isAfter(fajr)) return PrayerType.fajr;
    
    return null;
  }

  List<PrayerSchedule> getAllPrayerSchedules() {
    return [
      PrayerSchedule(type: PrayerType.fajr, time: fajr, name: 'Fajr'),
      PrayerSchedule(type: PrayerType.sunrise, time: sunrise, name: 'Sunrise'),
      PrayerSchedule(type: PrayerType.dhuhr, time: dhuhr, name: 'Dhuhr'),
      PrayerSchedule(type: PrayerType.asr, time: asr, name: 'Asr'),
      PrayerSchedule(type: PrayerType.maghrib, time: maghrib, name: 'Maghrib'),
      PrayerSchedule(type: PrayerType.isha, time: isha, name: 'Isha'),
      if (tahajjud != null)
        PrayerSchedule(type: PrayerType.tahajjud, time: tahajjud!, name: 'Tahajjud'),
    ];
  }

  PrayerTimesModel copyWith({
    String? id,
    DateTime? date,
    LocationModel? location,
    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
    DateTime? midnight,
    DateTime? tahajjud,
    String? calculationMethod,
    String? madhab,
    String? timezone,
    Map<String, int>? adjustments,
  }) {
    return PrayerTimesModel(
      id: id ?? this.id,
      date: date ?? this.date,
      location: location ?? this.location,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      midnight: midnight ?? this.midnight,
      tahajjud: tahajjud ?? this.tahajjud,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      timezone: timezone ?? this.timezone,
      adjustments: adjustments ?? this.adjustments,
    );
  }
}

@JsonSerializable()
class LocationModel {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String timezone;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.timezone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

@JsonEnum(fieldRename: FieldRename.snake)
enum PrayerType {
  @JsonValue('fajr') fajr,
  @JsonValue('sunrise')sunrise,
  @JsonValue('dhuhr')dhuhr,
  @JsonValue('asr')asr,
  @JsonValue('maghrib')maghrib,
  @JsonValue('isha')isha,
  @JsonValue('tahajjud')tahajjud;

  String get displayName => {
        PrayerType.fajr: 'Fajr',
        PrayerType.sunrise: 'Sunrise',
        PrayerType.dhuhr: 'Dhuhr',
        PrayerType.asr: 'Asr',
        PrayerType.maghrib: 'Maghrib',
        PrayerType.isha: 'Isha',
        PrayerType.tahajjud: 'Tahajjud',
      }[this]!;

  String get arabicName => {
        PrayerType.fajr: 'الفجر',
        PrayerType.sunrise: 'الشروق',
        PrayerType.dhuhr: 'الظهر',
        PrayerType.asr: 'العصر',
        PrayerType.maghrib: 'المغرب',
        PrayerType.isha: 'العشاء',
        PrayerType.tahajjud: 'التهجد',
      }[this]!;

  IconData get icon => {
        PrayerType.fajr: Icons.wb_twilight,
        PrayerType.sunrise: Icons.wb_sunny,
        PrayerType.dhuhr: Icons.wb_sunny_outlined,
        PrayerType.asr: Icons.wb_cloudy,
        PrayerType.maghrib: Icons.wb_twilight,
        PrayerType.isha: Icons.nights_stay,
        PrayerType.tahajjud: Icons.dark_mode,
      }[this]!;

  Color get color => {
        PrayerType.fajr: Colors.blue[300]!,
        PrayerType.sunrise: Colors.orange[400]!,
        PrayerType.dhuhr: Colors.yellow[600]!,
        PrayerType.asr: Colors.orange[600]!,
        PrayerType.maghrib: Colors.red[400]!,
        PrayerType.isha: Colors.indigo[400]!,
        PrayerType.tahajjud: Colors.purple[400]!,
      }[this]!;
}

class PrayerSchedule {
  final PrayerType type;
  final DateTime time;
  final String name;

  const PrayerSchedule({
    required this.type,
    required this.time,
    required this.name,
  });
}

// models/prayer/prayer_settings.dart
@JsonSerializable()
class PrayerSettings {
  final String calculationMethod;
  final String madhab;
  final Map<String, int> adjustments;
  final bool notificationsEnabled;
  final Map<String, bool> prayerNotifications;
  final bool adhanEnabled;
  final String adhanSound;
  final double adhanVolume;
  final bool vibrationEnabled;
  final int reminderMinutes;
  final bool locationAutoUpdate;
  final LocationModel? manualLocation;

  const PrayerSettings({
    this.calculationMethod = 'MWL',
    this.madhab = 'Shafi',
    this.adjustments = const {},
    this.notificationsEnabled = true,
    this.prayerNotifications = const {
      'fajr': true,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
      'tahajjud': false,
    },
    this.adhanEnabled = true,
    this.adhanSound = 'default',
    this.adhanVolume = 0.8,
    this.vibrationEnabled = true,
    this.reminderMinutes = 0,
    this.locationAutoUpdate = true,
    this.manualLocation,
  });

  factory PrayerSettings.fromJson(Map<String, dynamic> json) => _$PrayerSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerSettingsToJson(this);

  PrayerSettings copyWith({
    String? calculationMethod,
    String? madhab,
    Map<String, int>? adjustments,
    bool? notificationsEnabled,
    Map<String, bool>? prayerNotifications,
    bool? adhanEnabled,
    String? adhanSound,
    double? adhanVolume,
    bool? vibrationEnabled,
    int? reminderMinutes,
    bool? locationAutoUpdate,
    LocationModel? manualLocation,
  }) {
    return PrayerSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      adjustments: adjustments ?? this.adjustments,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      adhanSound: adhanSound ?? this.adhanSound,
      adhanVolume: adhanVolume ?? this.adhanVolume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      locationAutoUpdate: locationAutoUpdate ?? this.locationAutoUpdate,
      manualLocation: manualLocation ?? this.manualLocation,
    );
  }
}