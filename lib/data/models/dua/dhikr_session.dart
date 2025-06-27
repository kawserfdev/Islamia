import 'package:islamia/data/models/dua/dhikr_bead.dart';

class DhikrSession {
  final String id;
  final String userId;
  final String dhikrId;
  final String dhikrTitle;
  final int targetCount;
  final int currentCount;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final Duration? sessionDuration;
  final List<DhikrBead> beads;

  const DhikrSession({
    required this.id,
    required this.userId,
    required this.dhikrId,
    required this.dhikrTitle,
    required this.targetCount,
    this.currentCount = 0,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.sessionDuration,
    this.beads = const [],
  });

  factory DhikrSession.fromJson(Map<String, dynamic> json) {
    return DhikrSession(
      id: json['id'],
      userId: json['userId'],
      dhikrId: json['dhikrId'],
      dhikrTitle: json['dhikrTitle'],
      targetCount: json['targetCount'],
      currentCount: json['currentCount'] ?? 0,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isCompleted: json['isCompleted'] ?? false,
      sessionDuration: json['sessionDurationMs'] != null 
          ? Duration(milliseconds: json['sessionDurationMs']) 
          : null,
      beads: (json['beads'] as List?)?.map((e) => DhikrBead.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dhikrId': dhikrId,
      'dhikrTitle': dhikrTitle,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'sessionDurationMs': sessionDuration?.inMilliseconds,
      'beads': beads.map((e) => e.toJson()).toList(),
    };
  }

  double get progress => targetCount > 0 ? currentCount / targetCount : 0.0;
  int get remainingCount => targetCount - currentCount;
}
