// class RamadanDay {
//   final int dayNumber;
//   final DateTime date;
//   final DateTime suhoorTime;
//   final DateTime iftarTime;
//   final bool isFasted;
//   final String? intention;
//   final List<String> specialDua;
//   final String? quranReading;
//   final String? reflection;

//   const RamadanDay({
//     required this.dayNumber,
//     required this.date,
//     required this.suhoorTime,
//     required this.iftarTime,
//     this.isFasted = false,
//     this.intention,
//     this.specialDua = const [],
//     this.quranReading,
//     this.reflection,
//   });

//   factory RamadanDay.fromJson(Map<String, dynamic> json) {
//     return RamadanDay(
//       dayNumber: json['dayNumber'],
//       date: DateTime.parse(json['date']),
//       suhoorTime: DateTime.parse(json['suhoorTime']),
//       iftarTime: DateTime.parse(json['iftarTime']),
//       isFasted: json['isFasted'] ?? false,
//       intention: json['intention'],
//       specialDua: List<String>.from(json['specialDua'] ?? []),
//       quranReading: json['quranReading'],
//       reflection: json['reflection'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'dayNumber': dayNumber,
//       'date': date.toIso8601String(),
//       'suhoorTime': suhoorTime.toIso8601String(),
//       'iftarTime': iftarTime.toIso8601String(),
//       'isFasted': isFasted,
//       'intention': intention,
//       'specialDua': specialDua,
//       'quranReading': quranReading,
//       'reflection': reflection,
//     };
//   }
// }



















import 'dart:convert';

import 'package:islamia/data/models/calendar/hijri_date.dart';

class IslamicEvent {
  final String id;
  final String title;
  final String titleArabic;
  final String description;
  final String descriptionArabic;
  final DateTime gregorianDate;
  final HijriDate hijriDate;
  final IslamicEventType type;
  final IslamicEventCategory category;
  final bool isRecurring;
  final RecurrenceType? recurrenceType;
  final int? duration; // in days
  final String? imageUrl;
  final List<String> significances;
  final List<String> practices;
  final bool hasNotification;
  final DateTime? notificationTime;
  final String? source;
  final bool isUserCreated;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;

  const IslamicEvent({
    required this.id,
    required this.title,
    required this.titleArabic,
    required this.description,
    required this.descriptionArabic,
    required this.gregorianDate,
    required this.hijriDate,
    required this.type,
    required this.category,
    this.isRecurring = false,
    this.recurrenceType,
    this.duration,
    this.imageUrl,
    this.significances = const [],
    this.practices = const [],
    this.hasNotification = false,
    this.notificationTime,
    this.source,
    this.isUserCreated = false,
    required this.createdAt,
    this.updatedAt,
    this.metadata = const {},
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      id: json['id'],
      title: json['title'],
      titleArabic: json['title_arabic'],
      description: json['description'],
      descriptionArabic: json['description_arabic'],
      gregorianDate: DateTime.parse(json['gregorian_date']),
      hijriDate: HijriDate.fromJson(json['hijri_date'] is String 
          ? jsonDecode(json['hijri_date']) 
          : json['hijri_date']),
      type: IslamicEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IslamicEventType.religious,
      ),
      category: IslamicEventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => IslamicEventCategory.general,
      ),
      isRecurring: json['is_recurring'] == 1 || json['is_recurring'] == true,
      recurrenceType: json['recurrence_type'] != null
          ? RecurrenceType.values.firstWhere(
              (e) => e.name == json['recurrence_type'])
          : null,
      duration: json['duration'],
      imageUrl: json['image_url'],
      significances: json['significances'] is String
          ? List<String>.from(jsonDecode(json['significances']))
          : List<String>.from(json['significances'] ?? []),
      practices: json['practices'] is String
          ? List<String>.from(jsonDecode(json['practices']))
          : List<String>.from(json['practices'] ?? []),
      hasNotification: json['has_notification'] == 1 || json['has_notification'] == true,
      notificationTime: json['notification_time'] != null
          ? DateTime.parse(json['notification_time'])
          : null,
      source: json['source'],
      isUserCreated: json['is_user_created'] == 1 || json['is_user_created'] == true,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] is String
              ? DateTime.parse(json['updated_at'])
              : DateTime.fromMillisecondsSinceEpoch(json['updated_at']))
          : null,
      metadata: json['metadata'] is String
          ? Map<String, dynamic>.from(jsonDecode(json['metadata']))
          : Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_arabic': titleArabic,
      'description': description,
      'description_arabic': descriptionArabic,
      'gregorian_date': gregorianDate.toIso8601String(),
      'hijri_date': jsonEncode(hijriDate.toJson()),
      'type': type.name,
      'category': category.name,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_type': recurrenceType?.name,
      'duration': duration,
      'image_url': imageUrl,
      'significances': jsonEncode(significances),
      'practices': jsonEncode(practices),
      'has_notification': hasNotification ? 1 : 0,
      'notification_time': notificationTime?.toIso8601String(),
      'source': source,
      'is_user_created': isUserCreated ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'metadata': jsonEncode(metadata),
    };
  }

  IslamicEvent copyWith({
    String? id,
    String? title,
    String? titleArabic,
    String? description,
    String? descriptionArabic,
    DateTime? gregorianDate,
    HijriDate? hijriDate,
    IslamicEventType? type,
    IslamicEventCategory? category,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    int? duration,
    String? imageUrl,
    List<String>? significances,
    List<String>? practices,
    bool? hasNotification,
    DateTime? notificationTime,
    String? source,
    bool? isUserCreated,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return IslamicEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      titleArabic: titleArabic ?? this.titleArabic,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      gregorianDate: gregorianDate ?? this.gregorianDate,
      hijriDate: hijriDate ?? this.hijriDate,
      type: type ?? this.type,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      significances: significances ?? this.significances,
      practices: practices ?? this.practices,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationTime: notificationTime ?? this.notificationTime,
      source: source ?? this.source,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum IslamicEventType {
  religious,
  historical,
  personal,
  community,
  seasonal,
  lunar,
}

enum IslamicEventCategory {
  general,
  ramadan,
  hajj,
  eid,
  prophet,
  companions,
  islamic_months,
  sunnah_days,
  historic_battles,
  quran_revelation,
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
  hijri_yearly,
}

// models/calendar/moon_phase.dart
class MoonPhase {
  final DateTime date;
  final MoonPhaseType phase;
  final double illumination;
  final int age; // days since new moon
  final String phaseName;
  final String phaseNameArabic;
  final String description;

  const MoonPhase({
    required this.date,
    required this.phase,
    required this.illumination,
    required this.age,
    required this.phaseName,
    required this.phaseNameArabic,
    required this.description,
  });

  factory MoonPhase.fromJson(Map<String, dynamic> json) {
    return MoonPhase(
      date: DateTime.parse(json['date']),
      phase: MoonPhaseType.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => MoonPhaseType.newMoon,
      ),
      illumination: (json['illumination'] ?? 0.0).toDouble(),
      age: json['age'] ?? 0,
      phaseName: json['phase_name'],
      phaseNameArabic: json['phase_name_arabic'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'phase': phase.name,
      'illumination': illumination,
      'age': age,
      'phase_name': phaseName,
      'phase_name_arabic': phaseNameArabic,
      'description': description,
    };
  }
}

enum MoonPhaseType {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}