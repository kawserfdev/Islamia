import 'package:json_annotation/json_annotation.dart';

part 'reciter_model.g.dart';

@JsonSerializable()
class ReciterModel {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String? direction;
  final String? country;
  final String? profileImageUrl;
  final String? biography;
  final List<String> availableQualities;
  final bool isPopular;
  final int? totalDownloads;
  final double? rating;
  @JsonKey(unknownEnumValue: ReciterStyle.normal)
  final ReciterStyle style;

  const ReciterModel({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    this.direction,
    this.country,
    this.profileImageUrl,
    this.biography,
    this.availableQualities = const ['128kbps'],
    this.isPopular = false,
    this.totalDownloads,
    this.rating,
    this.style = ReciterStyle.normal,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) => _$ReciterModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReciterModelToJson(this);

  // Get audio URL for specific Surah
  String getAudioUrl(int surahNumber, {String quality = '128kbps'}) {
    final baseUrl = 'https://download.quranicaudio.com/quran';
    final paddedSurah = surahNumber.toString().padLeft(3, '0');
    
    // Different URL patterns for different reciters
    switch (identifier) {
      case 'ar.alafasy':
        return '$baseUrl/mishari_rashid_alafasy/$paddedSurah.mp3';
      case 'ar.husary':
        return '$baseUrl/mahmoud_khalil_al-hussary/$paddedSurah.mp3';
      case 'ar.sudais':
        return '$baseUrl/abdurrahman_as-sudais/$paddedSurah.mp3';
      case 'ar.shuraym':
        return '$baseUrl/saud_ash-shuraym/$paddedSurah.mp3';
      default:
        return '$baseUrl/${identifier.replaceAll('ar.', '')}/$paddedSurah.mp3';
    }
  }

  // Get ayah-specific audio URL
  String getAyahAudioUrl(int surahNumber, int ayahNumber) {
    final paddedSurah = surahNumber.toString().padLeft(3, '0');
    final paddedAyah = ayahNumber.toString().padLeft(3, '0');
    return 'https://verses.quran.com/${identifier}/$paddedSurah$paddedAyah.mp3';
  }

  ReciterModel copyWith({
    String? identifier,
    String? language,
    String? name,
    String? englishName,
    String? format,
    String? type,
    String? direction,
    String? country,
    String? profileImageUrl,
    String? biography,
    List<String>? availableQualities,
    bool? isPopular,
    int? totalDownloads,
    double? rating,
    ReciterStyle? style,
  }) {
    return ReciterModel(
      identifier: identifier ?? this.identifier,
      language: language ?? this.language,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      format: format ?? this.format,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      country: country ?? this.country,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      biography: biography ?? this.biography,
      availableQualities: availableQualities ?? this.availableQualities,
      isPopular: isPopular ?? this.isPopular,
      totalDownloads: totalDownloads ?? this.totalDownloads,
      rating: rating ?? this.rating,
      style: style ?? this.style,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterModel &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;
}

enum ReciterStyle {
  normal,
  tajweed,
  slow,
  fast,
  melodic,
  children;

  String get displayName {
    switch (this) {
      case ReciterStyle.normal:
        return 'Normal';
      case ReciterStyle.tajweed:
        return 'Tajweed';
      case ReciterStyle.slow:
        return 'Slow';
      case ReciterStyle.fast:
        return 'Fast';
      case ReciterStyle.melodic:
        return 'Melodic';
      case ReciterStyle.children:
        return 'Children';
    }
  }
}