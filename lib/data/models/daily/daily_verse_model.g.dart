// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_verse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyVerseModel _$DailyVerseModelFromJson(Map<String, dynamic> json) =>
    DailyVerseModel(
      number: (json['number'] as num).toInt(),
      text: json['text'] as String,
      translation: json['translation'] as String,
      surah: SurahInfo.fromJson(json['surah'] as Map<String, dynamic>),
      numberInSurah: (json['numberInSurah'] as num).toInt(),
    );

Map<String, dynamic> _$DailyVerseModelToJson(DailyVerseModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'text': instance.text,
      'translation': instance.translation,
      'surah': instance.surah,
      'numberInSurah': instance.numberInSurah,
    };

SurahInfo _$SurahInfoFromJson(Map<String, dynamic> json) => SurahInfo(
  number: (json['number'] as num).toInt(),
  name: json['name'] as String,
  englishName: json['englishName'] as String,
  englishNameTranslation: json['englishNameTranslation'] as String,
);

Map<String, dynamic> _$SurahInfoToJson(SurahInfo instance) => <String, dynamic>{
  'number': instance.number,
  'name': instance.name,
  'englishName': instance.englishName,
  'englishNameTranslation': instance.englishNameTranslation,
};
