import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/prayer/prayer_service.dart';
import 'package:islamia/core/utils/app_utils.dart';
import 'package:islamia/data/models/prayer/prayer_times.dart';

final prayerServiceProvider = Provider<PrayerService>((ref) {
  return PrayerService();
});

final prayerTimesProvider = FutureProvider.family<
  PrayerTimesModel,
  LocationData
>((ref, location) async {
  try {
    final service = ref.read(prayerServiceProvider);
    final result = await service.getTodayPrayerTimes(
      latitude: 23.8103,
      longitude: 90.4125,
    );
    print("Got prayer time: ${jsonEncode(result)}");
    return result;
  } catch (e) {
    print("Error getting prayer time: $e");
    //print(stack);
    rethrow;
  }
});


final nextPrayerProvider = Provider<NextPrayerInfo>((ref) {
  final prayerTimes = ref.watch(
    prayerTimesProvider(
      const LocationData(latitude: 23.8103, longitude: 90.4125),
    ),
  );

  return prayerTimes.when(
    data: (prayerTimes) {
      print("Nest Prayer Time First UI: $prayerTimes");
      return PrayerUtils.getNextPrayer(prayerTimes.timings);
    },
    loading:
        () => const NextPrayerInfo(
          name: 'Loading...',
          time: '',
          remainingTime: Duration.zero,
        ),
    error:
        (_, __) => const NextPrayerInfo(
          name: 'Error',
          time: '',
          remainingTime: Duration.zero,
        ),
  );
});

final islamicDateProvider = FutureProvider<IslamicDateInfo>((ref) async {
  final service = ref.read(prayerServiceProvider);
  return await service.getIslamicDate();
});

class LocationData {
  final double latitude;
  final double longitude;

  const LocationData({required this.latitude, required this.longitude});
}

class NextPrayerInfo {
  final String name;
  final String time;
  final Duration remainingTime;

  const NextPrayerInfo({
    required this.name,
    required this.time,
    required this.remainingTime,
  });
}
