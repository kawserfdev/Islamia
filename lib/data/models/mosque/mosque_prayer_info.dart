import 'package:islamia/data/models/prayer/prayer_times_model.dart';

class MosquePrayerInfo {
  final Map<PrayerType, String?> prayerTimes;
  final bool hasJummah;
  final String? jummahTime;
  final List<String> jummahKhateebs;
  final bool hasEidPrayers;
  final bool hasTarawih;
  final bool hasQiyamulLail;
  final String? imamName;
  final List<String> languages;
  final Map<String, String> specialPrayerTimes;

  const MosquePrayerInfo({
    this.prayerTimes = const {},
    this.hasJummah = true,
    this.jummahTime,
    this.jummahKhateebs = const [],
    this.hasEidPrayers = true,
    this.hasTarawih = false,
    this.hasQiyamulLail = false,
    this.imamName,
    this.languages = const ['Arabic'],
    this.specialPrayerTimes = const {},
  });

  factory MosquePrayerInfo.fromJson(Map<String, dynamic> json) {
    return MosquePrayerInfo(
      prayerTimes: (json['prayerTimes'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          PrayerType.values.firstWhere((e) => e.name == key),
          value as String?,
        ),
      ) ?? {},
      hasJummah: json['hasJummah'] ?? true,
      jummahTime: json['jummahTime'],
      jummahKhateebs: List<String>.from(json['jummahKhateebs'] ?? []),
      hasEidPrayers: json['hasEidPrayers'] ?? true,
      hasTarawih: json['hasTarawih'] ?? false,
      hasQiyamulLail: json['hasQiyamulLail'] ?? false,
      imamName: json['imamName'],
      languages: List<String>.from(json['languages'] ?? ['Arabic']),
      specialPrayerTimes: Map<String, String>.from(json['specialPrayerTimes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prayerTimes': prayerTimes.map((key, value) => MapEntry(key.name, value)),
      'hasJummah': hasJummah,
      'jummahTime': jummahTime,
      'jummahKhateebs': jummahKhateebs,
      'hasEidPrayers': hasEidPrayers,
      'hasTarawih': hasTarawih,
      'hasQiyamulLail': hasQiyamulLail,
      'imamName': imamName,
      'languages': languages,
      'specialPrayerTimes': specialPrayerTimes,
    };
  }
}

enum MosqueType {
  mosque,
  masjid,
  jameMasjid,
  eidgah,
  musalla,
  islamicCenter;

  String get displayName {
    switch (this) {
      case MosqueType.mosque:
        return 'Mosque';
      case MosqueType.masjid:
        return 'Masjid';
      case MosqueType.jameMasjid:
        return 'Jame Masjid';
      case MosqueType.eidgah:
        return 'Eidgah';
      case MosqueType.musalla:
        return 'Musalla';
      case MosqueType.islamicCenter:
        return 'Islamic Center';
    }
  }
}

enum MosqueFacility {
  parking,
  wheelchairAccess,
  ablutionArea,
  separateWomenSection,
  library,
  education,
  foodService,
  guestAccommodation,
  airConditioning,
  soundSystem,
  onlineStreaming,
  bookstore,
  cafe,
  childcare;

  String get displayName {
    switch (this) {
      case MosqueFacility.parking:
        return 'Parking Available';
      case MosqueFacility.wheelchairAccess:
        return 'Wheelchair Accessible';
      case MosqueFacility.ablutionArea:
        return 'Ablution Area';
      case MosqueFacility.separateWomenSection:
        return 'Separate Women Section';
      case MosqueFacility.library:
        return 'Library';
      case MosqueFacility.education:
        return 'Educational Programs';
      case MosqueFacility.foodService:
        return 'Food Service';
      case MosqueFacility.guestAccommodation:
        return 'Guest Accommodation';
      case MosqueFacility.airConditioning:
        return 'Air Conditioning';
      case MosqueFacility.soundSystem:
        return 'Sound System';
      case MosqueFacility.onlineStreaming:
        return 'Online Streaming';
      case MosqueFacility.bookstore:
        return 'Bookstore';
      case MosqueFacility.cafe:
        return 'Cafe';
      case MosqueFacility.childcare:
        return 'Childcare';
    }
  }
}