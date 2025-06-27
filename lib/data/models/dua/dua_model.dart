import 'package:islamia/data/models/dua/dhikr_bead.dart';

class Dua {
  final String id;
  final String title;
  final String titleArabic;
  final String arabicText;
  final String transliteration;
  final Map<String, String> translations;
  final String? reference;
  final DuaCategory category;
  final List<String> tags;
  final String? audioUrl;
  final bool isBookmarked;
  final DateTime? bookmarkedAt;
  final int? recitationCount;
  final DuaOccasion occasion;
  final String? benefits;
  final String? context;

  const Dua({
    required this.id,
    required this.title,
    required this.titleArabic,
    required this.arabicText,
    required this.transliteration,
    this.translations = const {},
    this.reference,
    required this.category,
    this.tags = const [],
    this.audioUrl,
    this.isBookmarked = false,
    this.bookmarkedAt,
    this.recitationCount,
    required this.occasion,
    this.benefits,
    this.context,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'],
      title: json['title'],
      titleArabic: json['titleArabic'],
      arabicText: json['arabicText'],
      transliteration: json['transliteration'],
      translations: Map<String, String>.from(json['translations'] ?? {}),
      reference: json['reference'],
      category: DuaCategory.values.firstWhere((e) => e.name == json['category']),
      tags: List<String>.from(json['tags'] ?? []),
      audioUrl: json['audioUrl'],
      isBookmarked: json['isBookmarked'] ?? false,
      bookmarkedAt: json['bookmarkedAt'] != null ? DateTime.parse(json['bookmarkedAt']) : null,
      recitationCount: json['recitationCount'],
      occasion: DuaOccasion.values.firstWhere((e) => e.name == json['occasion']),
      benefits: json['benefits'],
      context: json['context'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleArabic': titleArabic,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translations': translations,
      'reference': reference,
      'category': category.name,
      'tags': tags,
      'audioUrl': audioUrl,
      'isBookmarked': isBookmarked,
      'bookmarkedAt': bookmarkedAt?.toIso8601String(),
      'recitationCount': recitationCount,
      'occasion': occasion.name,
      'benefits': benefits,
      'context': context,
    };
  }
}
