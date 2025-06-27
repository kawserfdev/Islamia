import 'package:islamia/data/models/location/location.dart';

class PrayerLog {
  final String id;
  final String userId;
  final DateTime date;
  final PrayerType prayer;
  final DateTime? performedAt;
  final PrayerStatus status;
  final Location? location;
  final bool isQada;
  final String? notes;
  final bool isJamaat;
  final String? mosqueId;

  const PrayerLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.prayer,
    this.performedAt,
    required this.status,
    this.location,
    this.isQada = false,
    this.notes,
    this.isJamaat = false,
    this.mosqueId,
  });

  factory PrayerLog.fromJson(Map<String, dynamic> json) {
    return PrayerLog(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      prayer: PrayerType.values.firstWhere((e) => e.name == json['prayer']),
      performedAt: json['performedAt'] != null ? DateTime.parse(json['performedAt']) : null,
      status: PrayerStatus.values.firstWhere((e) => e.name == json['status']),
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      isQada: json['isQada'] ?? false,
      notes: json['notes'],
      isJamaat: json['isJamaat'] ?? false,
      mosqueId: json['mosqueId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'prayer': prayer.name,
      'performedAt': performedAt?.toIso8601String(),
      'status': status.name,
      'location': location?.toJson(),
      'isQada': isQada,
      'notes': notes,
      'isJamaat': isJamaat,
      'mosqueId': mosqueId,
    };
  }
}

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get displayName {
    switch (this) {
      case PrayerType.fajr:
        return 'Fajr';
      case PrayerType.sunrise:
        return 'Sunrise';
      case PrayerType.dhuhr:
        return 'Dhuhr';
      case PrayerType.asr:
        return 'Asr';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isha';
    }
  }

  String get arabicName {
    switch (this) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }
}

enum PrayerStatus {
  performed,
  missed,
  pending,
  qada;

  String get displayName {
    switch (this) {
      case PrayerStatus.performed:
        return 'Performed';
      case PrayerStatus.missed:
        return 'Missed';
      case PrayerStatus.pending:
        return 'Pending';
      case PrayerStatus.qada:
        return 'Qada';
    }
  }
}