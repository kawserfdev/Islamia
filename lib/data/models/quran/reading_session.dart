import 'package:islamia/data/models/quran/audio_recitation.dart';

class ReadingSession {
  final String id;
  final String userId;
  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final Duration readingTime;
  final DateTime startTime;
  final DateTime endTime;
  final ReadingMode mode;
  final List<String> completedAyahs;
  final Map<String, dynamic> metadata;

  const ReadingSession({
    required this.id,
    required this.userId,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.readingTime,
    required this.startTime,
    required this.endTime,
    required this.mode,
    this.completedAyahs = const [],
    this.metadata = const {},
  });

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'],
      userId: json['userId'],
      surahNumber: json['surahNumber'],
      startAyah: json['startAyah'],
      endAyah: json['endAyah'],
      readingTime: Duration(milliseconds: json['readingTimeMs']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      mode: ReadingMode.values.firstWhere((e) => e.name == json['mode']),
      completedAyahs: List<String>.from(json['completedAyahs'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'surahNumber': surahNumber,
      'startAyah': startAyah,
      'endAyah': endAyah,
      'readingTimeMs': readingTime.inMilliseconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'mode': mode.name,
      'completedAyahs': completedAyahs,
      'metadata': metadata,
    };
  }
}
