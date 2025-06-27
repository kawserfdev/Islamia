import 'package:islamia/data/models/dua/dhikr_bead.dart';
import 'package:islamia/data/models/dua/dua_reminder_time.dart';

class DuaReminder {
  final String id;
  final String userId;
  final String duaId;
  final String title;
  final List<DuaReminderTime> reminderTimes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? customMessage;
  final bool vibrationEnabled;
  final String? soundFile;
  final ReminderFrequency frequency;

  const DuaReminder({
    required this.id,
    required this.userId,
    required this.duaId,
    required this.title,
    this.reminderTimes = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.customMessage,
    this.vibrationEnabled = true,
    this.soundFile,
    this.frequency = ReminderFrequency.daily,
  });

  factory DuaReminder.fromJson(Map<String, dynamic> json) {
    return DuaReminder(
      id: json['id'],
      userId: json['userId'],
      duaId: json['duaId'],
      title: json['title'],
      reminderTimes: (json['reminderTimes'] as List?)
          ?.map((e) => DuaReminderTime.fromJson(e))
          .toList() ?? [],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      customMessage: json['customMessage'],
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      soundFile: json['soundFile'],
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ReminderFrequency.daily,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'duaId': duaId,
      'title': title,
      'reminderTimes': reminderTimes.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'customMessage': customMessage,
      'vibrationEnabled': vibrationEnabled,
      'soundFile': soundFile,
      'frequency': frequency.name,
    };
  }
}