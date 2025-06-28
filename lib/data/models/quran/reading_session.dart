import 'package:json_annotation/json_annotation.dart';

part 'reading_session.g.dart';

@JsonSerializable()
class ReadingSessionModel {
  final String id;
  final int surahNumber;
  final int lastAyahRead;
  final DateTime startTime;
  final DateTime lastReadTime;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration totalReadingTime;
  final int progressPercentage;

  const ReadingSessionModel({
    required this.id,
    required this.surahNumber,
    required this.lastAyahRead,
    required this.startTime,
    required this.lastReadTime,
    required this.totalReadingTime,
    required this.progressPercentage,
  });

  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) => _$ReadingSessionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingSessionModelToJson(this);

  static Duration _durationFromJson(int milliseconds) => Duration(milliseconds: milliseconds);
  static int _durationToJson(Duration duration) => duration.inMilliseconds;

  ReadingSessionModel copyWith({
    String? id,
    int? surahNumber,
    int? lastAyahRead,
    DateTime? startTime,
    DateTime? lastReadTime,
    Duration? totalReadingTime,
    int? progressPercentage,
  }) {
    return ReadingSessionModel(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      lastAyahRead: lastAyahRead ?? this.lastAyahRead,
      startTime: startTime ?? this.startTime,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}