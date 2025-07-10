// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithCollection _$HadithCollectionFromJson(Map<String, dynamic> json) =>
    HadithCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      arabicName: json['arabicName'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      totalHadith: (json['totalHadith'] as num).toInt(),
      totalBooks: (json['totalBooks'] as num).toInt(),
      books:
          (json['books'] as List<dynamic>?)
              ?.map((e) => HadithBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      coverImageUrl: json['coverImageUrl'] as String,
      availableLanguages:
          (json['availableLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['en', 'ar'],
      isAvailableOffline: json['isAvailableOffline'] as bool? ?? false,
    );

Map<String, dynamic> _$HadithCollectionToJson(HadithCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'arabicName': instance.arabicName,
      'author': instance.author,
      'description': instance.description,
      'totalHadith': instance.totalHadith,
      'totalBooks': instance.totalBooks,
      'books': instance.books,
      'coverImageUrl': instance.coverImageUrl,
      'availableLanguages': instance.availableLanguages,
      'isAvailableOffline': instance.isAvailableOffline,
    };

HadithBook _$HadithBookFromJson(Map<String, dynamic> json) => HadithBook(
  id: json['id'] as String,
  number: json['number'] as String,
  name: json['name'] as String,
  arabicName: json['arabicName'] as String,
  totalHadith: (json['totalHadith'] as num).toInt(),
  chapters:
      (json['chapters'] as List<dynamic>?)
          ?.map((e) => HadithChapter.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HadithBookToJson(HadithBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'name': instance.name,
      'arabicName': instance.arabicName,
      'totalHadith': instance.totalHadith,
      'chapters': instance.chapters,
    };

HadithChapter _$HadithChapterFromJson(Map<String, dynamic> json) =>
    HadithChapter(
      id: json['id'] as String,
      number: json['number'] as String,
      title: json['title'] as String,
      arabicTitle: json['arabicTitle'] as String,
      introduction: json['introduction'] as String?,
      totalHadith: (json['totalHadith'] as num).toInt(),
    );

Map<String, dynamic> _$HadithChapterToJson(HadithChapter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'title': instance.title,
      'arabicTitle': instance.arabicTitle,
      'introduction': instance.introduction,
      'totalHadith': instance.totalHadith,
    };
