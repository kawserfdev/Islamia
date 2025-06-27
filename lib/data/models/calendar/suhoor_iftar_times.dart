import 'package:islamia/data/models/calendar/fasting_time.dart';
import 'package:islamia/data/models/location/location.dart';

class SuhoorIftarTimes {
  final Location location;
  final Map<DateTime, FastingTime> times;

  const SuhoorIftarTimes({
    required this.location,
    this.times = const {},
  });

  factory SuhoorIftarTimes.fromJson(Map<String, dynamic> json) {
    return SuhoorIftarTimes(
      location: Location.fromJson(json['location']),
      times: (json['times'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(DateTime.parse(key), FastingTime.fromJson(value)),
      ) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'times': times.map((key, value) => MapEntry(key.toIso8601String(), value.toJson())),
    };
  }
}