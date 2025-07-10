import 'package:json_annotation/json_annotation.dart';
part 'hadith_category.g.dart';



@JsonSerializable()
class HadithCategory {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final int hadithCount;
  final String iconName;

  const HadithCategory({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.hadithCount,
    required this.iconName,
  });

  factory HadithCategory.fromJson(Map<String, dynamic> json) => _$HadithCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$HadithCategoryToJson(this);
}