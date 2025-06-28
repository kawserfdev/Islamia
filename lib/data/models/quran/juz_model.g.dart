// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'juz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JuzModel _$JuzModelFromJson(Map<String, dynamic> json) => JuzModel(
  number: (json['number'] as num).toInt(),
  name: json['name'] as String,
  surahs:
      (json['surahs'] as List<dynamic>)
          .map((e) => SurahInJuz.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$JuzModelToJson(JuzModel instance) => <String, dynamic>{
  'number': instance.number,
  'name': instance.name,
  'surahs': instance.surahs,
};

SurahInJuz _$SurahInJuzFromJson(Map<String, dynamic> json) => SurahInJuz(
  surahNumber: (json['surahNumber'] as num).toInt(),
  surahName: json['surahName'] as String,
  startVerse: (json['startVerse'] as num).toInt(),
  endVerse: (json['endVerse'] as num).toInt(),
);

Map<String, dynamic> _$SurahInJuzToJson(SurahInJuz instance) =>
    <String, dynamic>{
      'surahNumber': instance.surahNumber,
      'surahName': instance.surahName,
      'startVerse': instance.startVerse,
      'endVerse': instance.endVerse,
    };
