// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithModel _$HadithModelFromJson(Map<String, dynamic> json) => HadithModel(
  id: json['id'] as String,
  collection: json['collection'] as String,
  book: json['book'] as String,
  bookNumber: json['bookNumber'] as String,
  hadithNumber: json['hadithNumber'] as String,
  chapter: json['chapter'] as String,
  section: json['section'] as String,
  arabicText: json['arabicText'] as String,
  translations:
      (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  narrator: json['narrator'] as String,
  narratorChain: json['narratorChain'] as String,
  grade: $enumDecode(_$HadithGradeEnumMap, json['grade']),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  topics:
      (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  reference: json['reference'] as String?,
  commentary:
      (json['commentary'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  isBookmarked: json['isBookmarked'] as bool? ?? false,
  bookmarkedAt:
      json['bookmarkedAt'] == null
          ? null
          : DateTime.parse(json['bookmarkedAt'] as String),
);

Map<String, dynamic> _$HadithModelToJson(HadithModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collection': instance.collection,
      'book': instance.book,
      'bookNumber': instance.bookNumber,
      'hadithNumber': instance.hadithNumber,
      'chapter': instance.chapter,
      'section': instance.section,
      'arabicText': instance.arabicText,
      'translations': instance.translations,
      'narrator': instance.narrator,
      'narratorChain': instance.narratorChain,
      'grade': _$HadithGradeEnumMap[instance.grade]!,
      'tags': instance.tags,
      'topics': instance.topics,
      'reference': instance.reference,
      'commentary': instance.commentary,
      'isBookmarked': instance.isBookmarked,
      'bookmarkedAt': instance.bookmarkedAt?.toIso8601String(),
    };

const _$HadithGradeEnumMap = {
  HadithGrade.sahih: 'sahih',
  HadithGrade.hasan: 'hasan',
  HadithGrade.daif: 'daif',
  HadithGrade.maudu: 'maudu',
  HadithGrade.unknown: 'unknown',
};
