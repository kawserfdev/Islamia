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

  factory HadithChapter.fromJson(Map<String, dynamic> json) {
    return HadithChapter(
      id: json['id'],
      number: json['number'],
      title: json['title'],
      arabicTitle: json['arabicTitle'],
      introduction: json['introduction'],
      totalHadith: json['totalHadith'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'arabicTitle': arabicTitle,
      'introduction': introduction,
      'totalHadith': totalHadith,
    };
  }
}
