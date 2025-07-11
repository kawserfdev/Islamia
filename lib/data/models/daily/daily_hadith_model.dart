import 'package:json_annotation/json_annotation.dart';
part 'daily_hadith_model.g.dart';

@JsonSerializable()
class DailyHadithModel {
  final String arab;
  final String english;
  final String source;
  final String grade;

  const DailyHadithModel({
    required this.arab,
    required this.english,
    required this.source,
    required this.grade,
  });

  factory DailyHadithModel.fromJson(Map<String, dynamic> json) =>
      _$DailyHadithModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyHadithModelToJson(this);
}