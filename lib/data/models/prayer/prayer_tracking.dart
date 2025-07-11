import 'package:islamia/data/models/prayer/prayer_times_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prayer_tracking.g.dart';


@JsonSerializable()
class PrayerTracking {
  final String id;
  final DateTime date;

  @JsonKey(unknownEnumValue: PrayerType.fajr)
  final PrayerType prayerType;

  final DateTime? prayedAt;
  final bool isQaza;
  final String? note;

  const PrayerTracking({
    required this.id,
    required this.date,
    required this.prayerType,
    this.prayedAt,
    this.isQaza = false,
    this.note,
  });

  /// JSON
  factory PrayerTracking.fromJson(Map<String, dynamic> json) =>
      _$PrayerTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$PrayerTrackingToJson(this);

  bool get isPrayed => prayedAt != null;

  bool get isMissed => !isPrayed && !isQaza && DateTime.now().isAfter(date);

  PrayerTracking copyWith({
    String? id,
    DateTime? date,
    PrayerType? prayerType,
    DateTime? prayedAt,
    bool? isQaza,
    String? note,
  }) {
    return PrayerTracking(
      id: id ?? this.id,
      date: date ?? this.date,
      prayerType: prayerType ?? this.prayerType,
      prayedAt: prayedAt ?? this.prayedAt,
      isQaza: isQaza ?? this.isQaza,
      note: note ?? this.note,
    );
  }
}

@JsonSerializable()
class QazaCounter {
  final Map<String, int> missedPrayers;
  final DateTime lastUpdated;

  const QazaCounter({
    this.missedPrayers = const {
      'fajr': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    },
    required this.lastUpdated,
  });

  factory QazaCounter.fromJson(Map<String, dynamic> json) => _$QazaCounterFromJson(json);
  Map<String, dynamic> toJson() => _$QazaCounterToJson(this);

  int get totalMissed => missedPrayers.values.fold(0, (sum, count) => sum + count);

  QazaCounter copyWith({
    Map<String, int>? missedPrayers,
    DateTime? lastUpdated,
  }) {
    return QazaCounter(
      missedPrayers: missedPrayers ?? this.missedPrayers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
