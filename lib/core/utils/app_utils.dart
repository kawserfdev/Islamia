import 'package:islamia/core/constants/app_constants.dart';
import 'package:islamia/data/models/prayer/prayer_times.dart';
import 'package:islamia/presentation/providers/prayer_provider.dart';

class IslamicUtils {
  static Map<String, String> getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    String timeOfDay;
    if (hour >= 5 && hour < 12) {
      timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }

    return AppConstants.islamicGreetings[timeOfDay]!;
  }

  static String formatIslamicDate(String day, String month, String year) {
    return '$day $month $year';
  }

  static List<String> getIslamicMonths() {
    return [
      'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
  }
}



class PrayerUtils {
  static NextPrayerInfo getNextPrayer(PrayerTimings timings) {
    final now = DateTime.now();
    final prayers = timings.prayersList;
    
    for (final prayer in prayers) {
      final prayerTime = _parseTime(prayer.time);
      if (prayerTime.isAfter(now)) {
        final remaining = prayerTime.difference(now);
        return NextPrayerInfo(
          name: prayer.name,
          time: prayer.time,
          remainingTime: remaining,
        );
      }
    }
    
    // If all prayers have passed, return tomorrow's Fajr
    final tomorrow = now.add(const Duration(days: 1));
    final fajrTime = _parseTime(timings.fajr);
    final tomorrowFajr = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, fajrTime.hour, fajrTime.minute);
    
    return NextPrayerInfo(
      name: 'Fajr',
      time: timings.fajr,
      remainingTime: tomorrowFajr.difference(now),
    );
  }

  static DateTime _parseTime(String timeString) {
    final parts = timeString.split(' ');
    final time = parts[0].split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}