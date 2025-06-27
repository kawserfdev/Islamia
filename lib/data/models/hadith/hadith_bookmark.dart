class HadithBookmark {
  final String id;
  final String userId;
  final String hadithId;
  final String collection;
  final String hadithNumber;
  final String hadithText;
  final String? note;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPrivate;

  const HadithBookmark({
    required this.id,
    required this.userId,
    required this.hadithId,
    required this.collection,
    required this.hadithNumber,
    required this.hadithText,
    this.note,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isPrivate = true,
  });

  factory HadithBookmark.fromJson(Map<String, dynamic> json) {
    return HadithBookmark(
      id: json['id'],
      userId: json['userId'],
      hadithId: json['hadithId'],
      collection: json['collection'],
      hadithNumber: json['hadithNumber'],
      hadithText: json['hadithText'],
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isPrivate: json['isPrivate'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hadithId': hadithId,
      'collection': collection,
      'hadithNumber': hadithNumber,
      'hadithText': hadithText,
      'note': note,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPrivate': isPrivate,
    };
  }
}

enum HadithGrade {
  sahih,
  hasan,
  daif,
  maudu,
  unknown;

  String get displayName {
    switch (this) {
      case HadithGrade.sahih:
        return 'Sahih (Authentic)';
      case HadithGrade.hasan:
        return 'Hasan (Good)';
      case HadithGrade.daif:
        return 'Da\'if (Weak)';
      case HadithGrade.maudu:
        return 'Maudu (Fabricated)';
      case HadithGrade.unknown:
        return 'Unknown';
    }
  }
}