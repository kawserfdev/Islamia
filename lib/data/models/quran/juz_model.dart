import 'package:islamia/data/models/quran/surah_range.dart';

class Juz {
  final int number;
  final String name;
  final List<SurahRange> surahs;
  final int startAyahNumber;
  final int endAyahNumber;
  final int totalAyahs;

  const Juz({
    required this.number,
    required this.name,
    required this.surahs,
    required this.startAyahNumber,
    required this.endAyahNumber,
    required this.totalAyahs,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      number: json['number'],
      name: json['name'],
      surahs: (json['surahs'] as List).map((e) => SurahRange.fromJson(e)).toList(),
      startAyahNumber: json['startAyahNumber'],
      endAyahNumber: json['endAyahNumber'],
      totalAyahs: json['totalAyahs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'surahs': surahs.map((e) => e.toJson()).toList(),
      'startAyahNumber': startAyahNumber,
      'endAyahNumber': endAyahNumber,
      'totalAyahs': totalAyahs,
    };
  }
}