// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AyahModel _$AyahModelFromJson(Map<String, dynamic> json) => AyahModel(
  number: (json['number'] as num).toInt(),
  text: json['text'] as String,
  surahNumber: (json['surahNumber'] as num).toInt(),
  ayahNumber: (json['ayahNumber'] as num).toInt(),
  juz: (json['juz'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  translations:
      (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  audioUrl: json['audioUrl'] as String?,
);

Map<String, dynamic> _$AyahModelToJson(AyahModel instance) => <String, dynamic>{
  'number': instance.number,
  'text': instance.text,
  'surahNumber': instance.surahNumber,
  'ayahNumber': instance.ayahNumber,
  'juz': instance.juz,
  'page': instance.page,
  'translations': instance.translations,
  'audioUrl': instance.audioUrl,
};
