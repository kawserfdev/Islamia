// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_bookmark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithBookmark _$HadithBookmarkFromJson(Map<String, dynamic> json) =>
    HadithBookmark(
      id: json['id'] as String,
      hadithId: json['hadithId'] as String,
      collection: json['collection'] as String,
      hadithNumber: json['hadithNumber'] as String,
      hadithText: json['hadithText'] as String,
      note: json['note'] as String?,
      category: json['category'] as String? ?? 'General',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$HadithBookmarkToJson(HadithBookmark instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hadithId': instance.hadithId,
      'collection': instance.collection,
      'hadithNumber': instance.hadithNumber,
      'hadithText': instance.hadithText,
      'note': instance.note,
      'category': instance.category,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
