// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookmarkModel _$BookmarkModelFromJson(Map<String, dynamic> json) =>
    BookmarkModel(
      id: json['id'] as String,
      surahNumber: (json['surahNumber'] as num).toInt(),
      ayahNumber: (json['ayahNumber'] as num).toInt(),
      surahName: json['surahName'] as String,
      ayahText: json['ayahText'] as String,
      note: json['note'] as String?,
      category: json['category'] as String? ?? 'General',
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$BookmarkModelToJson(BookmarkModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'surahNumber': instance.surahNumber,
      'ayahNumber': instance.ayahNumber,
      'surahName': instance.surahName,
      'ayahText': instance.ayahText,
      'note': instance.note,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
    };
