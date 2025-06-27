import 'package:islamia/data/models/calendar/islamic_date.dart';

class IslamicEvent {
  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final EventType type;
  final EventImportance importance;
  final IslamicDate date;
  final bool isRecurring;
  final String? customColor;
  final List<String> relatedPrayers;
  final List<String> recommendedActions;
  final String? hadithReference;
  final String? quranReference;

  const IslamicEvent({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.type,
    required this.importance,
    required this.date,
    this.isRecurring = true,
    this.customColor,
    this.relatedPrayers = const [],
    this.recommendedActions = const [],
    this.hadithReference,
    this.quranReference,
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      id: json['id'],
      name: json['name'],
      nameArabic: json['nameArabic'],
      description: json['description'],
      type: EventType.values.firstWhere((e) => e.name == json['type']),
        importance: EventImportance.values.firstWhere((e) => e.name == json['importance']),
      date: IslamicDate.fromJson(json['date']),
      isRecurring: json['isRecurring'] ?? true,
      customColor: json['customColor'],
      relatedPrayers: List<String>.from(json['relatedPrayers'] ?? []),
      recommendedActions: List<String>.from(json['recommendedActions'] ?? []),
      hadithReference: json['hadithReference'],
      quranReference: json['quranReference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'description': description,
      'type': type.name,
      'importance': importance.name,
      'date': date.toJson(),
      'isRecurring': isRecurring,
      'customColor': customColor,
      'relatedPrayers': relatedPrayers,
      'recommendedActions': recommendedActions,
      'hadithReference': hadithReference,
      'quranReference': quranReference,
    };
  }
}

enum EventType {
  religious,
  historical,
  lunar,
  pilgrimage,
  fasting,
  charity,
  prayer,
  celebration;

  String get displayName {
    switch (this) {
      case EventType.religious:
        return 'Religious';
      case EventType.historical:
        return 'Historical';
      case EventType.lunar:
        return 'Lunar';
      case EventType.pilgrimage:
        return 'Pilgrimage';
      case EventType.fasting:
        return 'Fasting';
      case EventType.charity:
        return 'Charity';
      case EventType.prayer:
        return 'Prayer';
      case EventType.celebration:
        return 'Celebration';
    }
  }
}

enum EventImportance {
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case EventImportance.high:
        return 'High';
      case EventImportance.medium:
        return 'Medium';
      case EventImportance.low:
        return 'Low';
    }
  }
}
