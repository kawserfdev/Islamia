class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final int? revelationOrder;
  final int? rukuCount;
  final int? manzilNumber;
  final int? hizbQuarterNumber;
  final int? sajdahNumber;
  final int juzNumber;
  final Map<String, String> translations;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.revelationOrder,
    this.rukuCount,
    this.manzilNumber,
    this.hizbQuarterNumber,
    this.sajdahNumber,
    required this.juzNumber,
    this.translations = const {},
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
      revelationOrder: json['revelationOrder'],
      rukuCount: json['rukuCount'],
      manzilNumber: json['manzilNumber'],
      hizbQuarterNumber: json['hizbQuarterNumber'],
      sajdahNumber: json['sajdahNumber'],
      juzNumber: json['juzNumber'],
      translations: Map<String, String>.from(json['translations'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
      'revelationOrder': revelationOrder,
      'rukuCount': rukuCount,
      'manzilNumber': manzilNumber,
      'hizbQuarterNumber': hizbQuarterNumber,
      'sajdahNumber': sajdahNumber,
      'juzNumber': juzNumber,
      'translations': translations,
    };
  }
}