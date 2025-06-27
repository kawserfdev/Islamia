import 'package:islamia/data/models/calendar/ramadan_day.dart';
import 'package:islamia/data/models/calendar/suhoor_iftar_times.dart';

class RamadanInfo {
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final List<RamadanDay> days;
  final Map<String, DateTime> specialNights;
  final List<String> dua;
  final SuhoorIftarTimes suhoorIftarTimes;

  const RamadanInfo({
    required this.year,
    required this.startDate,
    required this.endDate,
    this.days = const [],
    this.specialNights = const {},
    this.dua = const [],
    required this.suhoorIftarTimes,
  });

  factory RamadanInfo.fromJson(Map<String, dynamic> json) {
    return RamadanInfo(
      year: json['year'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      days: (json['days'] as List?)?.map((e) => RamadanDay.fromJson(e)).toList() ?? [],
      specialNights: (json['specialNights'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, DateTime.parse(value)),
      ) ?? {},
      dua: List<String>.from(json['dua'] ?? []),
      suhoorIftarTimes: SuhoorIftarTimes.fromJson(json['suhoorIftarTimes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'days': days.map((e) => e.toJson()).toList(),
      'specialNights': specialNights.map((key, value) => MapEntry(key, value.toIso8601String())),
      'dua': dua,
      'suhoorIftarTimes': suhoorIftarTimes.toJson(),
    };
  }

  int get totalDays => endDate.difference(startDate).inDays + 1;
  bool get isActive => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
}
