// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reciter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReciterModel _$ReciterModelFromJson(Map<String, dynamic> json) => ReciterModel(
  identifier: json['identifier'] as String,
  language: json['language'] as String,
  name: json['name'] as String,
  englishName: json['englishName'] as String,
  format: json['format'] as String,
  type: json['type'] as String,
  direction: json['direction'] as String?,
  country: json['country'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  biography: json['biography'] as String?,
  availableQualities:
      (json['availableQualities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['128kbps'],
  isPopular: json['isPopular'] as bool? ?? false,
  totalDownloads: (json['totalDownloads'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  style:
      $enumDecodeNullable(
        _$ReciterStyleEnumMap,
        json['style'],
        unknownValue: ReciterStyle.normal,
      ) ??
      ReciterStyle.normal,
);

Map<String, dynamic> _$ReciterModelToJson(ReciterModel instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'language': instance.language,
      'name': instance.name,
      'englishName': instance.englishName,
      'format': instance.format,
      'type': instance.type,
      'direction': instance.direction,
      'country': instance.country,
      'profileImageUrl': instance.profileImageUrl,
      'biography': instance.biography,
      'availableQualities': instance.availableQualities,
      'isPopular': instance.isPopular,
      'totalDownloads': instance.totalDownloads,
      'rating': instance.rating,
      'style': _$ReciterStyleEnumMap[instance.style]!,
    };

const _$ReciterStyleEnumMap = {
  ReciterStyle.normal: 'normal',
  ReciterStyle.tajweed: 'tajweed',
  ReciterStyle.slow: 'slow',
  ReciterStyle.fast: 'fast',
  ReciterStyle.melodic: 'melodic',
  ReciterStyle.children: 'children',
};
