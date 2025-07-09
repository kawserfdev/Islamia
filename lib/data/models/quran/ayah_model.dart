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
  final int? manzil;
  final int? ruku;
  final int? hizbQuarter;
  final Map<String, String> translations;
  final Map<String, String>? transliterations;
  final Map<String, String>? tafsir;
  final String? audioUrl;

  const AyahModel({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.ayahNumber,
    required this.juz,
    required this.page,
    this.manzil,
    this.ruku,
    this.hizbQuarter,
    this.translations = const {},
    this.transliterations,
    this.tafsir,
    this.audioUrl,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) =>
      _$AyahModelFromJson(json);

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
      manzil: arabicData['manzil'],
      ruku: arabicData['ruku'],
      hizbQuarter: arabicData['hizbQuarter'],
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
      manzil: data['manzil'],
      ruku: data['ruku'],
      hizbQuarter: data['hizbQuarter'],
      audioUrl: data['audio'],
    );
  }

  int get numberInSurah => ayahNumber;

  String get displayReference => '$surahNumber:$ayahNumber';

  String getTranslation(String translationCode) {
    return translations[translationCode] ??
        translations['en'] ??
        translations.values.firstOrNull ??
        '';
  }

  String? getTransliteration(String code) => transliterations?[code];

  String? getTafsir(String code) => tafsir?[code];

  bool hasTranslation(String code) => translations.containsKey(code);

  List<String> get availableTranslations => translations.keys.toList();

  String get primaryTranslation => translations.values.firstOrNull ?? '';

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  AyahModel copyWith({
    int? number,
    String? text,
    int? surahNumber,
    int? ayahNumber,
    int? juz,
    int? page,
    int? manzil,
    int? ruku,
    int? hizbQuarter,
    Map<String, String>? translations,
    Map<String, String>? transliterations,
    Map<String, String>? tafsir,
    String? audioUrl,
  }) {
    return AyahModel(
      number: number ?? this.number,
      text: text ?? this.text,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      manzil: manzil ?? this.manzil,
      ruku: ruku ?? this.ruku,
      hizbQuarter: hizbQuarter ?? this.hizbQuarter,
      translations: translations ?? this.translations,
      transliterations: transliterations ?? this.transliterations,
      tafsir: tafsir ?? this.tafsir,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  AyahModel addTranslation(String languageCode, String translation) {
    final updatedTranslations = Map<String, String>.from(translations);
    updatedTranslations[languageCode] = translation;
    return copyWith(translations: updatedTranslations);
  }

  AyahModel removeTranslation(String languageCode) {
    final updatedTranslations = Map<String, String>.from(translations);
    updatedTranslations.remove(languageCode);
    return copyWith(translations: updatedTranslations);
  }

  String getShareText({
    String? translationCode,
    String? surahName,
    bool includeReference = true,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(text);
    buffer.writeln();

    if (translationCode != null) {
      final translation = getTranslation(translationCode);
      if (translation.isNotEmpty) {
        buffer.writeln(translation);
        buffer.writeln();
      }
    }

    if (includeReference) {
      final reference = surahName != null
          ? '- $surahName $ayahNumber:$surahNumber'
          : '- Surah $surahNumber, Ayah $ayahNumber';
      buffer.write(reference);
    }

    return buffer.toString();
  }

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
    return 'AyahModel(number: $number, surah: $surahNumber, ayah: $ayahNumber, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...)';
  }
}
