import 'package:json_annotation/json_annotation.dart';

part 'daily_verse_model.g.dart';

@JsonSerializable()
class DailyVerseModel {
  final int number;
  final String text;
  final String translation;
  final SurahInfo surah;
  final int numberInSurah;

  const DailyVerseModel({
    required this.number,
    required this.text,
    required this.translation,
    required this.surah,
    required this.numberInSurah,
  });

  factory DailyVerseModel.fromJson(Map<String, dynamic> json) =>
      _$DailyVerseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyVerseModelToJson(this);
}

@JsonSerializable()
class SurahInfo {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) =>
      _$SurahInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SurahInfoToJson(this);
}