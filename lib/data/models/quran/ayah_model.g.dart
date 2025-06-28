// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AyahModel _$AyahModelFromJson(Map<String, dynamic> json) => AyahModel(
  number: (json['number'] as num).toInt(),
  text: json['text'] as String,
  surah: (json['surah'] as num).toInt(),
  numberInSurah: (json['numberInSurah'] as num).toInt(),
  juz: (json['juz'] as num).toInt(),
  manzil: (json['manzil'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  ruku: (json['ruku'] as num).toInt(),
  hizbQuarter: (json['hizbQuarter'] as num).toInt(),
  sajda: json['sajda'] as bool? ?? false,
  translations: (json['translations'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  audioUrl: json['audioUrl'] as String?,
);

Map<String, dynamic> _$AyahModelToJson(AyahModel instance) => <String, dynamic>{
  'number': instance.number,
  'text': instance.text,
  'surah': instance.surah,
  'numberInSurah': instance.numberInSurah,
  'juz': instance.juz,
  'manzil': instance.manzil,
  'page': instance.page,
  'ruku': instance.ruku,
  'hizbQuarter': instance.hizbQuarter,
  'sajda': instance.sajda,
  'translations': instance.translations,
  'audioUrl': instance.audioUrl,
};
