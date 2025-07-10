// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithCategory _$HadithCategoryFromJson(Map<String, dynamic> json) =>
    HadithCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      arabicName: json['arabicName'] as String,
      description: json['description'] as String,
      hadithCount: (json['hadithCount'] as num).toInt(),
      iconName: json['iconName'] as String,
    );

Map<String, dynamic> _$HadithCategoryToJson(HadithCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'arabicName': instance.arabicName,
      'description': instance.description,
      'hadithCount': instance.hadithCount,
      'iconName': instance.iconName,
    };
