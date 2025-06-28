import 'package:json_annotation/json_annotation.dart';

part 'surah_model.g.dart';

@JsonSerializable()
class SurahModel {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final int? revelationOrder;

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.revelationOrder,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) => _$SurahModelFromJson(json);
  Map<String, dynamic> toJson() => _$SurahModelToJson(this);

  bool get isMakki => revelationType.toLowerCase() == 'meccan';
  bool get isMadani => revelationType.toLowerCase() == 'medinan';
}