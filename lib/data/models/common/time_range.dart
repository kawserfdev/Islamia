import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: TimeOfDay(
        hour: json['startHour'],
        minute: json['startMinute'],
      ),
      end: TimeOfDay(
        hour: json['endHour'],
        minute: json['endMinute'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startHour': start.hour,
      'startMinute': start.minute,
      'endHour': end.hour,
      'endMinute': end.minute,
    };
  }

  bool contains(TimeOfDay time) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final timeMinutes = time.hour * 60 + time.minute;

    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Handles overnight ranges
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}