import 'package:json_annotation/json_annotation.dart';

part 'ayah_model.g.dart';

@JsonSerializable()
class AyahModel {
  final int number;
  final String text;
  final int surahNumber;
  final int ayahNumber;
  final int juz;
  final int page;
  final Map<String, String> translations;
  final String? audioUrl;

  const AyahModel({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.ayahNumber,
    required this.juz,
    required this.page,
    this.translations = const {},
    this.audioUrl,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) => _$AyahModelFromJson(json);
  Map<String, dynamic> toJson() => _$AyahModelToJson(this);

  factory AyahModel.fromCombinedData(
    Map<String, dynamic> arabicData,
    Map<String, dynamic>? translationData,
  ) {
    return AyahModel(
      number: arabicData['number'],
      text: arabicData['text'],
      surahNumber: arabicData['surah']['number'],
      ayahNumber: arabicData['numberInSurah'],
      juz: arabicData['juz'] ?? 1,
      page: arabicData['page'] ?? 1,
      translations: translationData != null 
          ? {'en': translationData['text']}
          : {},
      audioUrl: arabicData['audio'],
    );
  }

  factory AyahModel.fromApiResponse(Map<String, dynamic> data) {
    return AyahModel(
      number: data['number'],
      text: data['text'],
      surahNumber: data['surah']?['number'] ?? 1,
      ayahNumber: data['numberInSurah'] ?? 1,
      juz: data['juz'] ?? 1,
      page: data['page'] ?? 1,
      audioUrl: data['audio'],
    );
  }

  // Getter for backward compatibility with your existing code
  int get numberInSurah => ayahNumber;

  // Display reference format
  String get displayReference => '$surahNumber:$ayahNumber';

  // Get translation by language code
  String getTranslation(String translationCode) {
    return translations[translationCode] ?? 
           translations['en'] ?? 
           translations.values.firstOrNull ?? 
           '';
  }

  // Check if translation exists for given language
  bool hasTranslation(String translationCode) {
    return translations.containsKey(translationCode);
  }

  // Get all available translation languages
  List<String> get availableTranslations => translations.keys.toList();

  // Get primary translation (first available)
  String get primaryTranslation => translations.values.firstOrNull ?? '';

  // Check if ayah has audio
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  // Copy with method for immutable updates
  AyahModel copyWith({
    int? number,
    String? text,
    int? surahNumber,
    int? ayahNumber,
    int? juz,
    int? page,
    Map<String, String>? translations,
    String? audioUrl,
  }) {
    return AyahModel(
      number: number ?? this.number,
      text: text ?? this.text,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      translations: translations ?? this.translations,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  // Add translation to existing translations
  AyahModel addTranslation(String languageCode, String translation) {
    final updatedTranslations = Map<String, String>.from(translations);
    updatedTranslations[languageCode] = translation;
    return copyWith(translations: updatedTranslations);
  }

  // Remove translation
  AyahModel removeTranslation(String languageCode) {
    final updatedTranslations = Map<String, String>.from(translations);
    updatedTranslations.remove(languageCode);
    return copyWith(translations: updatedTranslations);
  }

  // Get formatted text for sharing
  String getShareText({
    String? translationCode,
    String? surahName,
    bool includeReference = true,
  }) {
    final buffer = StringBuffer();
    
    // Add Arabic text
    buffer.writeln(text);
    buffer.writeln();
    
    // Add translation if available
    if (translationCode != null) {
      final translation = getTranslation(translationCode);
      if (translation.isNotEmpty) {
        buffer.writeln(translation);
        buffer.writeln();
      }
    }
    
    // Add reference
    if (includeReference) {
      final reference = surahName != null 
          ? '- $surahName $ayahNumber:$surahNumber'
          : '- Surah $surahNumber, Ayah $ayahNumber';
      buffer.write(reference);
    }
    
    return buffer.toString();
  }

  // Check equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahModel &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => Object.hash(number, surahNumber, ayahNumber);

  @override
  String toString() {
    return 'AyahModel(number: $number, surahNumber: $surahNumber, ayahNumber: $ayahNumber, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...)';
  }
}
