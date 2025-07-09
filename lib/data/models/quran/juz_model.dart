import 'package:json_annotation/json_annotation.dart';

part 'juz_model.g.dart';

@JsonSerializable()
class JuzModel {
  final int number;
  final String name;
  final List<SurahInJuz> surahs;
  final int startAyahNumber;
  final int endAyahNumber;
  final int totalAyahs;

  const JuzModel({
    required this.number,
    required this.name,
    required this.surahs,
    required this.startAyahNumber,
    required this.endAyahNumber,
    required this.totalAyahs,
  });

  factory JuzModel.fromJson(Map<String, dynamic> json) => _$JuzModelFromJson(json);
  Map<String, dynamic> toJson() => _$JuzModelToJson(this);
}
@JsonSerializable()
class SurahInJuz {
  final int surahNumber;
  final String surahName;
  final int startVerse;
  final int endVerse;

  const SurahInJuz({
    required this.surahNumber,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
  });

  factory SurahInJuz.fromJson(Map<String, dynamic> json) => _$SurahInJuzFromJson(json);
  Map<String, dynamic> toJson() => _$SurahInJuzToJson(this);
}
