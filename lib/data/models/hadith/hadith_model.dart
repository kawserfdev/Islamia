import 'package:islamia/data/models/hadith/hadith_bookmark.dart';

class Hadith {
  final String id;
  final String collection;
  final String bookNumber;
  final String hadithNumber;
  final String chapter;
  final String section;
  final String arabicText;
  final Map<String, String> translations;
  final String narrator;
  final HadithGrade grade;
  final List<String> tags;
  final List<String> topics;
  final String? reference;
  final Map<String, String> commentary;
  final bool isBookmarked;
  final DateTime? bookmarkedAt;

  const Hadith({
    required this.id,
    required this.collection,
    required this.bookNumber,
    required this.hadithNumber,
    required this.chapter,
    required this.section,
    required this.arabicText,
    this.translations = const {},
    required this.narrator,
    required this.grade,
    this.tags = const [],
    this.topics = const [],
    this.reference,
    this.commentary = const {},
    this.isBookmarked = false,
    this.bookmarkedAt,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'],
      collection: json['collection'],
      bookNumber: json['bookNumber'],
      hadithNumber: json['hadithNumber'],
      chapter: json['chapter'],
      section: json['section'],
      arabicText: json['arabicText'],
      translations: Map<String, String>.from(json['translations'] ?? {}),
      narrator: json['narrator'],
      grade: HadithGrade.values.firstWhere((e) => e.name == json['grade']),
      tags: List<String>.from(json['tags'] ?? []),
      topics: List<String>.from(json['topics'] ?? []),
      reference: json['reference'],
      commentary: Map<String, String>.from(json['commentary'] ?? {}),
      isBookmarked: json['isBookmarked'] ?? false,
      bookmarkedAt: json['bookmarkedAt'] != null ? DateTime.parse(json['bookmarkedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection': collection,
      'bookNumber': bookNumber,
      'hadithNumber': hadithNumber,
      'chapter': chapter,
      'section': section,
      'arabicText': arabicText,
      'translations': translations,
      'narrator': narrator,
      'grade': grade.name,
      'tags': tags,
      'topics': topics,
      'reference': reference,
      'commentary': commentary,
      'isBookmarked': isBookmarked,
      'bookmarkedAt': bookmarkedAt?.toIso8601String(),
    };
  }
}