import 'dart:convert';

import 'package:islamia/data/models/calendar/hijri_date.dart';

class DailyReminder {
  final String id;
  final DateTime date;
  final HijriDate hijriDate;
  final String quranVerse;
  final String quranVerseArabic;
  final String translation;
  final String hadith;
  final String hadithArabic;
  final String hadithSource;
  final String islamicQuote;
  final String islamicQuoteArabic;
  final String author;
  final List<String> dailyPractices;
  final List<String> supplications;
  final String moonPhaseInfo;
  final DateTime createdAt;

  const DailyReminder({
    required this.id,
    required this.date,
    required this.hijriDate,
    required this.quranVerse,
    required this.quranVerseArabic,
    required this.translation,
    required this.hadith,
    required this.hadithArabic,
    required this.hadithSource,
    required this.islamicQuote,
    required this.islamicQuoteArabic,
    required this.author,
    this.dailyPractices = const [],
    this.supplications = const [],
    required this.moonPhaseInfo,
    required this.createdAt,
  });

  factory DailyReminder.fromJson(Map<String, dynamic> json) {
    return DailyReminder(
      id: json['id'],
      date: DateTime.parse(json['date']),
      hijriDate: HijriDate.fromJson(json['hijri_date'] is String
          ? jsonDecode(json['hijri_date'])
          : json['hijri_date']),
      quranVerse: json['quran_verse'],
      quranVerseArabic: json['quran_verse_arabic'],
      translation: json['translation'],
      hadith: json['hadith'],
      hadithArabic: json['hadith_arabic'],
      hadithSource: json['hadith_source'],
      islamicQuote: json['islamic_quote'],
      islamicQuoteArabic: json['islamic_quote_arabic'],
      author: json['author'],
      dailyPractices: json['daily_practices'] is String
          ? List<String>.from(jsonDecode(json['daily_practices']))
          : List<String>.from(json['daily_practices'] ?? []),
      supplications: json['supplications'] is String
          ? List<String>.from(jsonDecode(json['supplications']))
          : List<String>.from(json['supplications'] ?? []),
      moonPhaseInfo: json['moon_phase_info'],
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'hijri_date': jsonEncode(hijriDate.toJson()),
      'quran_verse': quranVerse,
      'quran_verse_arabic': quranVerseArabic,
      'translation': translation,
      'hadith': hadith,
      'hadith_arabic': hadithArabic,
      'hadith_source': hadithSource,
      'islamic_quote': islamicQuote,
      'islamic_quote_arabic': islamicQuoteArabic,
      'author': author,
      'daily_practices': jsonEncode(dailyPractices),
      'supplications': jsonEncode(supplications),
      'moon_phase_info': moonPhaseInfo,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}