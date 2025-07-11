// import 'package:islamia/data/models/hadith/hadith_bookmark.dart';

// class Hadith {
//   final String id;
//   final String collection;
//   final String bookNumber;
//   final String hadithNumber;
//   final String chapter;
//   final String section;
//   final String arabicText;
//   final Map<String, String> translations;
//   final String narrator;
//   final HadithGrade grade;
//   final List<String> tags;
//   final List<String> topics;
//   final String? reference;
//   final Map<String, String> commentary;
//   final bool isBookmarked;
//   final DateTime? bookmarkedAt;

//   const Hadith({
//     required this.id,
//     required this.collection,
//     required this.bookNumber,
//     required this.hadithNumber,
//     required this.chapter,
//     required this.section,
//     required this.arabicText,
//     this.translations = const {},
//     required this.narrator,
//     required this.grade,
//     this.tags = const [],
//     this.topics = const [],
//     this.reference,
//     this.commentary = const {},
//     this.isBookmarked = false,
//     this.bookmarkedAt,
//   });

//   factory Hadith.fromJson(Map<String, dynamic> json) {
//     return Hadith(
//       id: json['id'],
//       collection: json['collection'],
//       bookNumber: json['bookNumber'],
//       hadithNumber: json['hadithNumber'],
//       chapter: json['chapter'],
//       section: json['section'],
//       arabicText: json['arabicText'],
//       translations: Map<String, String>.from(json['translations'] ?? {}),
//       narrator: json['narrator'],
//       grade: HadithGrade.values.firstWhere((e) => e.name == json['grade']),
//       tags: List<String>.from(json['tags'] ?? []),
//       topics: List<String>.from(json['topics'] ?? []),
//       reference: json['reference'],
//       commentary: Map<String, String>.from(json['commentary'] ?? {}),
//       isBookmarked: json['isBookmarked'] ?? false,
//       bookmarkedAt: json['bookmarkedAt'] != null ? DateTime.parse(json['bookmarkedAt']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'collection': collection,
//       'bookNumber': bookNumber,
//       'hadithNumber': hadithNumber,
//       'chapter': chapter,
//       'section': section,
//       'arabicText': arabicText,
//       'translations': translations,
//       'narrator': narrator,
//       'grade': grade.name,
//       'tags': tags,
//       'topics': topics,
//       'reference': reference,
//       'commentary': commentary,
//       'isBookmarked': isBookmarked,
//       'bookmarkedAt': bookmarkedAt?.toIso8601String(),
//     };
//   }
// }




import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'hadith_model.g.dart';

@JsonSerializable()
class HadithModel {
  final String id;
  final String collection;
  final String book;
  final String bookNumber;
  final String hadithNumber;
  final String chapter;
  final String section;
  final String arabicText;
  final Map<String, String> translations;
  final String narrator;
  final String narratorChain;
  final HadithGrade grade;
  final List<String> tags;
  final List<String> topics;
  final String? reference;
  final Map<String, String> commentary;
  final bool isBookmarked;
  final DateTime? bookmarkedAt;

  const HadithModel({
    required this.id,
    required this.collection,
    required this.book,
    required this.bookNumber,
    required this.hadithNumber,
    required this.chapter,
    required this.section,
    required this.arabicText,
    this.translations = const {},
    required this.narrator,
    required this.narratorChain,
    required this.grade,
    this.tags = const [],
    this.topics = const [],
    this.reference,
    this.commentary = const {},
    this.isBookmarked = false,
    this.bookmarkedAt,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) => _$HadithModelFromJson(json);
  Map<String, dynamic> toJson() => _$HadithModelToJson(this);

  String getTranslation(String languageCode) {
    return translations[languageCode] ?? 
           translations['en'] ?? 
           translations.values.firstOrNull ?? 
           '';
  }

  String get displayReference => '$collection - $book $hadithNumber';

  String getShareText({
    String? languageCode,
    bool includeNarrator = true,
    bool includeReference = true,
  }) {
    final buffer = StringBuffer();
    
    // Add Arabic text
    buffer.writeln(arabicText);
    buffer.writeln();
    
    // Add translation if available
    if (languageCode != null) {
      final translation = getTranslation(languageCode);
      if (translation.isNotEmpty) {
        buffer.writeln(translation);
        buffer.writeln();
      }
    }
    
    // Add narrator
    if (includeNarrator) {
      buffer.writeln('Narrator: $narrator');
      buffer.writeln();
    }
    
    // Add reference
    if (includeReference) {
      buffer.writeln('Reference: $displayReference');
      buffer.writeln('Grade: ${grade.displayName}');
    }
    
    return buffer.toString();
  }

  HadithModel copyWith({
    String? id,
    String? collection,
    String? book,
    String? bookNumber,
    String? hadithNumber,
    String? chapter,
    String? section,
    String? arabicText,
    Map<String, String>? translations,
    String? narrator,
    String? narratorChain,
    HadithGrade? grade,
    List<String>? tags,
    List<String>? topics,
    String? reference,
    Map<String, String>? commentary,
    bool? isBookmarked,
    DateTime? bookmarkedAt,
  }) {
    return HadithModel(
      id: id ?? this.id,
      collection: collection ?? this.collection,
      book: book ?? this.book,
      bookNumber: bookNumber ?? this.bookNumber,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      chapter: chapter ?? this.chapter,
      section: section ?? this.section,
      arabicText: arabicText ?? this.arabicText,
      translations: translations ?? this.translations,
      narrator: narrator ?? this.narrator,
      narratorChain: narratorChain ?? this.narratorChain,
      grade: grade ?? this.grade,
      tags: tags ?? this.tags,
      topics: topics ?? this.topics,
      reference: reference ?? this.reference,
      commentary: commentary ?? this.commentary,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
    );
  }
}

enum HadithGrade {
  sahih,
  hasan,
  daif,
  maudu,
  unknown;

  String get displayName {
    switch (this) {
      case HadithGrade.sahih:
        return 'Sahih (Authentic)';
      case HadithGrade.hasan:
        return 'Hasan (Good)';
      case HadithGrade.daif:
        return 'Da\'if (Weak)';
      case HadithGrade.maudu:
        return 'Maudu (Fabricated)';
      case HadithGrade.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case HadithGrade.sahih:
        return Colors.green;
      case HadithGrade.hasan:
        return Colors.blue;
      case HadithGrade.daif:
        return Colors.orange;
      case HadithGrade.maudu:
        return Colors.red;
      case HadithGrade.unknown:
        return Colors.grey;
    }
  }
}