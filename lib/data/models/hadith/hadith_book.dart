import 'package:islamia/data/models/hadith/hadith_chapter.dart';

class HadithBook {
  final String id;
  final String number;
  final String name;
  final String arabicName;
  final int totalHadith;
  final List<HadithChapter> chapters;

  const HadithBook({
    required this.id,
    required this.number,
    required this.name,
    required this.arabicName,
    required this.totalHadith,
    this.chapters = const [],
  });

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      id: json['id'],
      number: json['number'],
      name: json['name'],
      arabicName: json['arabicName'],
      totalHadith: json['totalHadith'],
      chapters: (json['chapters'] as List?)?.map((e) => HadithChapter.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'arabicName': arabicName,
      'totalHadith': totalHadith,
      'chapters': chapters.map((e) => e.toJson()).toList(),
    };
  }
}