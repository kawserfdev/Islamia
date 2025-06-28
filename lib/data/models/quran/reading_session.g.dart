// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingSessionModel _$ReadingSessionModelFromJson(Map<String, dynamic> json) =>
    ReadingSessionModel(
      id: json['id'] as String,
      surahNumber: (json['surahNumber'] as num).toInt(),
      lastAyahRead: (json['lastAyahRead'] as num).toInt(),
      startTime: DateTime.parse(json['startTime'] as String),
      lastReadTime: DateTime.parse(json['lastReadTime'] as String),
      totalReadingTime: ReadingSessionModel._durationFromJson(
        (json['totalReadingTime'] as num).toInt(),
      ),
      progressPercentage: (json['progressPercentage'] as num).toInt(),
    );

Map<String, dynamic> _$ReadingSessionModelToJson(
  ReadingSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'surahNumber': instance.surahNumber,
  'lastAyahRead': instance.lastAyahRead,
  'startTime': instance.startTime.toIso8601String(),
  'lastReadTime': instance.lastReadTime.toIso8601String(),
  'totalReadingTime': ReadingSessionModel._durationToJson(
    instance.totalReadingTime,
  ),
  'progressPercentage': instance.progressPercentage,
};
