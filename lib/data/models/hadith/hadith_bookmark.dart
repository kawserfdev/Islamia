import 'package:json_annotation/json_annotation.dart';
part 'hadith_bookmark.g.dart';


@JsonSerializable()
class HadithBookmark {
  final String id;
  final String hadithId;
  final String collection;
  final String hadithNumber;
  final String hadithText;
  final String? note;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HadithBookmark({
    required this.id,
    required this.hadithId,
    required this.collection,
    required this.hadithNumber,
    required this.hadithText,
    this.note,
    this.category = 'General',
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory HadithBookmark.fromJson(Map<String, dynamic> json) => _$HadithBookmarkFromJson(json);
  Map<String, dynamic> toJson() => _$HadithBookmarkToJson(this);

  HadithBookmark copyWith({
    String? id,
    String? hadithId,
    String? collection,
    String? hadithNumber,
    String? hadithText,
    String? note,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HadithBookmark(
      id: id ?? this.id,
      hadithId: hadithId ?? this.hadithId,
      collection: collection ?? this.collection,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      hadithText: hadithText ?? this.hadithText,
      note: note ?? this.note,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}