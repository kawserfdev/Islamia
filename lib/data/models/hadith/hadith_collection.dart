import 'package:islamia/data/models/hadith/hadith_book.dart';

class HadithCollection {
  final String id;
  final String name;
  final String arabicName;
  final String author;
  final String description;
  final int totalHadith;
  final int totalBooks;
  final List<HadithBook> books;
  final String language;
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
    required this.language,
    this.isAvailableOffline = false,
  });

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabicName'],
      author: json['author'],
      description: json['description'],
      totalHadith: json['totalHadith'],
      totalBooks: json['totalBooks'],
      books: (json['books'] as List?)?.map((e) => HadithBook.fromJson(e)).toList() ?? [],
      language: json['language'],
      isAvailableOffline: json['isAvailableOffline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'author': author,
      'description': description,
      'totalHadith': totalHadith,
      'totalBooks': totalBooks,
      'books': books.map((e) => e.toJson()).toList(),
      'language': language,
      'isAvailableOffline': isAvailableOffline,
    };
  }
}