// class HadithBookmark {
//   final String id;
//   final String userId;
//   final String hadithId;
//   final String collection;
//   final String hadithNumber;
//   final String hadithText;
//   final String? note;
//   final List<String> tags;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final bool isPrivate;

//   const HadithBookmark({
//     required this.id,
//     required this.userId,
//     required this.hadithId,
//     required this.collection,
//     required this.hadithNumber,
//     required this.hadithText,
//     this.note,
//     this.tags = const [],
//     required this.createdAt,
//     this.updatedAt,
//     this.isPrivate = true,
//   });

//   factory HadithBookmark.fromJson(Map<String, dynamic> json) {
//     return HadithBookmark(
//       id: json['id'],
//       userId: json['userId'],
//       hadithId: json['hadithId'],
//       collection: json['collection'],
//       hadithNumber: json['hadithNumber'],
//       hadithText: json['hadithText'],
//       note: json['note'],
//       tags: List<String>.from(json['tags'] ?? []),
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
//       isPrivate: json['isPrivate'] ?? true,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'hadithId': hadithId,
//       'collection': collection,
//       'hadithNumber': hadithNumber,
//       'hadithText': hadithText,
//       'note': note,
//       'tags': tags,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//       'isPrivate': isPrivate,
//     };
//   }
// }

// enum HadithGrade {
//   sahih,
//   hasan,
//   daif,
//   maudu,
//   unknown;

//   String get displayName {
//     switch (this) {
//       case HadithGrade.sahih:
//         return 'Sahih (Authentic)';
//       case HadithGrade.hasan:
//         return 'Hasan (Good)';
//       case HadithGrade.daif:
//         return 'Da\'if (Weak)';
//       case HadithGrade.maudu:
//         return 'Maudu (Fabricated)';
//       case HadithGrade.unknown:
//         return 'Unknown';
//     }
//   }
// }


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