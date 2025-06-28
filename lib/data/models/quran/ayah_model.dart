import 'package:json_annotation/json_annotation.dart';

part 'ayah_model.g.dart';

@JsonSerializable()
class AyahModel {
  final int number;
  final String text;
  final int surah;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;
  final Map<String, String>? translations;
  final String? audioUrl;

  const AyahModel({
    required this.number,
    required this.text,
    required this.surah,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    this.sajda = false,
    this.translations,
    this.audioUrl,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) => _$AyahModelFromJson(json);
  Map<String, dynamic> toJson() => _$AyahModelToJson(this);

  String getTranslation(String language) {
    return translations?[language] ?? '';
  }

  AyahModel copyWith({
    Map<String, String>? translations,
    String? audioUrl,
  }) {
    return AyahModel(
      number: number,
      text: text,
      surah: surah,
      numberInSurah: numberInSurah,
      juz: juz,
      manzil: manzil,
      page: page,
      ruku: ruku,
      hizbQuarter: hizbQuarter,
      sajda: sajda,
      translations: translations ?? this.translations,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}