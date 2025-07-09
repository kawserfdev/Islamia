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
  manzil: (json['manzil'] as num?)?.toInt(),
  ruku: (json['ruku'] as num?)?.toInt(),
  hizbQuarter: (json['hizbQuarter'] as num?)?.toInt(),
  translations:
      (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  transliterations: (json['transliterations'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  tafsir: (json['tafsir'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  audioUrl: json['audioUrl'] as String?,
);

Map<String, dynamic> _$AyahModelToJson(AyahModel instance) => <String, dynamic>{
  'number': instance.number,
  'text': instance.text,
  'surahNumber': instance.surahNumber,
  'ayahNumber': instance.ayahNumber,
  'juz': instance.juz,
  'page': instance.page,
  'manzil': instance.manzil,
  'ruku': instance.ruku,
  'hizbQuarter': instance.hizbQuarter,
  'translations': instance.translations,
  'transliterations': instance.transliterations,
  'tafsir': instance.tafsir,
  'audioUrl': instance.audioUrl,
};
