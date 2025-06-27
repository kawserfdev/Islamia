class QuranBookmark {
  final String id;
  final String userId;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahText;
  final String? note;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPrivate;
  final int? colorCode;

  const QuranBookmark({
    required this.id,
    required this.userId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahText,
    this.note,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isPrivate = true,
    this.colorCode,
  });

  factory QuranBookmark.fromJson(Map<String, dynamic> json) {
    return QuranBookmark(
      id: json['id'],
      userId: json['userId'],
      surahNumber: json['surahNumber'],
      ayahNumber: json['ayahNumber'],
      surahName: json['surahName'],
      ayahText: json['ayahText'],
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isPrivate: json['isPrivate'] ?? true,
      colorCode: json['colorCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
      'ayahText': ayahText,
      'note': note,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPrivate': isPrivate,
      'colorCode': colorCode,
    };
  }
}