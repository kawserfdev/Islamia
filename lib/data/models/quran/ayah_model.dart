import 'package:islamia/data/models/quran/audio_recitation.dart';

class Ayah {
  final int number;
  final String text;
  final int surahNumber;
  final int ayahNumber;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;
  final Map<String, String> translations;
  final Map<String, String> transliterations;
  final Map<String, String> tafsir;
  final Map<String, AudioRecitation> audioRecitations;

  const Ayah({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.ayahNumber,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    this.sajda = false,
    this.translations = const {},
    this.transliterations = const {},
    this.tafsir = const {},
    this.audioRecitations = const {},
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'],
      text: json['text'],
      surahNumber: json['surahNumber'],
      ayahNumber: json['ayahNumber'],
      juz: json['juz'],
      manzil: json['manzil'],
      page: json['page'],
      ruku: json['ruku'],
      hizbQuarter: json['hizbQuarter'],
      sajda: json['sajda'] ?? false,
      translations: Map<String, String>.from(json['translations'] ?? {}),
      transliterations: Map<String, String>.from(json['transliterations'] ?? {}),
      tafsir: Map<String, String>.from(json['tafsir'] ?? {}),
      audioRecitations: (json['audioRecitations'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, AudioRecitation.fromJson(value)),
      ) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'juz': juz,
      'manzil': manzil,
      'page': page,
      'ruku': ruku,
      'hizbQuarter': hizbQuarter,
      'sajda': sajda,
      'translations': translations,
      'transliterations': transliterations,
      'tafsir': tafsir,
      'audioRecitations': audioRecitations.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
