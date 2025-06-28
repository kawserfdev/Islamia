// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_hadith_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyHadithModel _$DailyHadithModelFromJson(Map<String, dynamic> json) =>
    DailyHadithModel(
      arab: json['arab'] as String,
      english: json['english'] as String,
      source: json['source'] as String,
      grade: json['grade'] as String,
    );

Map<String, dynamic> _$DailyHadithModelToJson(DailyHadithModel instance) =>
    <String, dynamic>{
      'arab': instance.arab,
      'english': instance.english,
      'source': instance.source,
      'grade': instance.grade,
    };
