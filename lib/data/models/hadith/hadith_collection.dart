import 'package:json_annotation/json_annotation.dart';
part 'hadith_collection.g.dart';

// class HadithCollection {
//   final String id;
//   final String name;
//   final String arabicName;
//   final String author;
//   final String description;
//   final int totalHadith;
//   final int totalBooks;
//   final List<HadithBook> books;
//   final String language;
//   final bool isAvailableOffline;

//   const HadithCollection({
//     required this.id,
//     required this.name,
//     required this.arabicName,
//     required this.author,
//     required this.description,
//     required this.totalHadith,
//     required this.totalBooks,
//     this.books = const [],
//     required this.language,
//     this.isAvailableOffline = false,
//   });

//   factory HadithCollection.fromJson(Map<String, dynamic> json) {
//     return HadithCollection(
//       id: json['id'],
//       name: json['name'],
//       arabicName: json['arabicName'],
//       author: json['author'],
//       description: json['description'],
//       totalHadith: json['totalHadith'],
//       totalBooks: json['totalBooks'],
//       books: (json['books'] as List?)?.map((e) => HadithBook.fromJson(e)).toList() ?? [],
//       language: json['language'],
//       isAvailableOffline: json['isAvailableOffline'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'arabicName': arabicName,
//       'author': author,
//       'description': description,
//       'totalHadith': totalHadith,
//       'totalBooks': totalBooks,
//       'books': books.map((e) => e.toJson()).toList(),
//       'language': language,
//       'isAvailableOffline': isAvailableOffline,
//     };
//   }
// }




@JsonSerializable()
class HadithCollection {
  final String id;
  final String name;
  final String arabicName;
  final String author;
  final String description;
  final int totalHadith;
  final int totalBooks;
  final List<HadithBook> books;
  final String coverImageUrl;
  final List<String> availableLanguages;
  final bool isAvailableOffline;

  const HadithCollection({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.author,
    required this.description,
    required this.totalHadith,
    required this.totalBooks,
    this.books = const [],
    required this.coverImageUrl,
    this.availableLanguages = const ['en', 'ar'],
    this.isAvailableOffline = false,
  });

  factory HadithCollection.fromJson(Map<String, dynamic> json) => _$HadithCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$HadithCollectionToJson(this);
}

@JsonSerializable()
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

  factory HadithBook.fromJson(Map<String, dynamic> json) => _$HadithBookFromJson(json);
  Map<String, dynamic> toJson() => _$HadithBookToJson(this);
}

@JsonSerializable()
class HadithChapter {
  final String id;
  final String number;
  final String title;
  final String arabicTitle;
  final String? introduction;
  final int totalHadith;

  const HadithChapter({
    required this.id,
    required this.number,
    required this.title,
    required this.arabicTitle,
    this.introduction,
    required this.totalHadith,
  });

  factory HadithChapter.fromJson(Map<String, dynamic> json) => _$HadithChapterFromJson(json);
  Map<String, dynamic> toJson() => _$HadithChapterToJson(this);
}