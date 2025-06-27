import 'package:flutter/material.dart';

class DuaReminderTime {
  final String id;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 1-7, Monday-Sunday
  final bool isActive;

  const DuaReminderTime({
    required this.id,
    required this.time,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.isActive = true,
  });

  factory DuaReminderTime.fromJson(Map<String, dynamic> json) {
    return DuaReminderTime(
      id: json['id'],
      time: TimeOfDay(
        hour: json['hour'],
        minute: json['minute'],
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
    };
  }
}
