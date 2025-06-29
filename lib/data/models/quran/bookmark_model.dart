import 'package:json_annotation/json_annotation.dart';

part 'bookmark_model.g.dart';



@JsonSerializable()
class BookmarkModel {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahText;
  final String? note;
  final String category;
  final DateTime createdAt;
  final List<String> tags;

  const BookmarkModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahText,
    this.note,
    this.category = 'General',
    required this.createdAt,
    this.tags = const [],
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) => _$BookmarkModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarkModelToJson(this);

  String get displayText => '$surahName $ayahNumber:$surahNumber';

  BookmarkModel copyWith({
    String? id,
    int? surahNumber,
    int? ayahNumber,
    String? surahName,
    String? ayahText,
    String? note,
    String? category,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      surahName: surahName ?? this.surahName,
      ayahText: ayahText ?? this.ayahText,
      note: note ?? this.note,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }
}
