import 'dart:math' as math;
import '../models/calendar/hijri_date.dart';
import '../database/calendar_database.dart';

class HijriService {
  final CalendarDatabase _database = CalendarDatabase();

  // Islamic month names
  static const List<String> _monthNames = [
    'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
    'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
  ];

  static const List<String> _monthNamesArabic = [
    'مُحَرَّم', 'صَفَر', 'رَبِيع الأَوَّل', 'رَبِيع الثَّانِي',
    'جُمَادَى الأُولَى', 'جُمَادَى الثَّانِيَة', 'رَجَب', 'شَعْبَان',
    'رَمَضَان', 'شَوَّال', 'ذُو القِعْدَة', 'ذُو الحِجَّة'
  ];

  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _dayNamesArabic = [
    'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
    'الجمعة', 'السبت', 'الأحد'
  ];

  // Convert Gregorian date to Hijri
  Future<HijriDate> gregorianToHijri(DateTime gregorianDate) async {
    // Check cache first
    final cached = await _database.getCachedHijriDate(gregorianDate);
    if (cached != null) {
      return cached;
    }

    // Perform conversion using Kuwaiti algorithm
    final hijriDate = _convertGregorianToHijri(gregorianDate);
    
    // Cache the result
    await _database.cacheHijriDate(gregorianDate, hijriDate);
    
    return hijriDate;
  }

  // Convert Hijri date to Gregorian
  DateTime hijriToGregorian(int hijriDay, int hijriMonth, int hijriYear) {
    return _convertHijriToGregorian(hijriDay, hijriMonth, hijriYear);
  }

  // Get current Hijri date
  Future<HijriDate> getCurrentHijriDate() async {
    return await gregorianToHijri(DateTime.now());
  }

  // Internal conversion method (Kuwaiti Algorithm)
  HijriDate _convertGregorianToHijri(DateTime gregorianDate) {
    int gYear = gregorianDate.year;
    int gMonth = gregorianDate.month;
    int gDay = gregorianDate.day;

    // Calculate Julian Day Number
    int jd;
    if (gMonth <= 2) {
      gYear -= 1;
      gMonth += 12;
    }

    int a = (gYear / 100).floor();
    int b = 2 - a + (a / 4).floor();

    if (gYear < 1583 || (gYear == 1583 && gMonth < 10) || 
        (gYear == 1583 && gMonth == 10 && gDay < 15)) {
      b = 0;
    }

    jd = (365.25 * (gYear + 4716)).floor() + 
         (30.6001 * (gMonth + 1)).floor() + 
         gDay + b - 1524;

    // Convert Julian Day to Hijri
    jd = jd - 1948084 + 1;
    int hYear = (30 * jd + 10646) ~/ 10631;
    int hMonth = ((jd - 29 - _yearLength(hYear - 1)) * 12) ~/ 354;
    int hDay = jd - 29 - _yearLength(hYear - 1) - _monthLength(hMonth, hYear) + 1;

    if (hMonth >= 12) {
      hMonth = hMonth - 12;
      hYear = hYear + 1;
    }
    if (hMonth < 0) {
      hMonth = hMonth + 12;
      hYear = hYear - 1;
    }
    if (hDay <= 0) {
      hMonth = hMonth - 1;
      if (hMonth < 0) {
        hMonth = hMonth + 12;
        hYear = hYear - 1;
      }
      hDay = hDay + _monthDays(hMonth, hYear);
    }

    hMonth += 1; // Adjust for 1-based indexing

    return HijriDate(
      day: hDay,
      month: hMonth,
      year: hYear,
      monthName: _monthNames[hMonth - 1],
      monthNameArabic: _monthNamesArabic[hMonth - 1],
      dayName: _dayNames[gregorianDate.weekday - 1],
      dayNameArbic: _dayNamesArabic[gregorianDate.weekday - 1],
      isLeapYear: _isHijriLeapYear(hYear),
      weekDay: gregorianDate.weekday,
    );
  }

  // Convert Hijri to Gregorian
  DateTime _convertHijriToGregorian(int hDay, int hMonth, int hYear) {
    int jd = (hDay + _monthLength(hMonth - 1, hYear) + _yearLength(hYear - 1) + 1948085).floor();
    
    int l = jd + 68569;
    int n = (4 * l / 146097).floor();
    l = l - ((146097 * n + 3) / 4).floor();
    int i = (4000 * (l + 1) / 1461001).floor();
    l = l - (1461 * i / 4).floor() + 31;
    int j = (80 * l / 2447).floor();
    int gDay = l - (2447 * j / 80).floor();
    l = (j / 11).floor();
    int gMonth = j + 2 - 12 * l;
    int gYear = 100 * (n - 49) + i + l;

    return DateTime(gYear, gMonth, gDay);
  }

  // Helper methods
  int _yearLength(int year) {
    int sum = 0;
    for (int month = 0; month < 12; month++) {
      sum += _monthDays(month, year);
    }
    return sum;
  }

  int _monthLength(int month, int year) {
    int sum = 0;
    for (int m = 0; m < month; m++) {
      sum += _monthDays(m, year);
    }
    return sum;
  }

  int _monthDays(int month, int year) {
    // Alternating 30 and 29 days, with adjustment for leap years
    if (month.isEven) {
      return 30;
    } else if (month == 11 && _isHijriLeapYear(year)) {
      return 30;
    } else {
      return 29;
    }
  }

  bool _isHijriLeapYear(int year) {
    // Simple leap year calculation for Hijri calendar
    return ((year * 11 + 14) % 30) < 11;
  }


    static String getMonthName(int month, {bool isArabic = false}) {
    if (month < 1 || month > 12) return '';
    return isArabic ? _monthNamesArabic[month - 1] : _monthNames[month - 1];
  }

  // Get day name
  static String getDayName(int weekday, {bool isArabic = false}) {
    if (weekday < 1 || weekday > 7) return '';
    return isArabic ? _dayNamesArabic[weekday - 1] : _dayNames[weekday - 1];
  }

  // Get days in Hijri month
  static int getDaysInHijriMonth(int month, int year) {
    if (month == 12 && _isHijriLeapYear(year)) {
      return 30;
    }
    return month.isEven ? 30 : 29;
  }

  // Get Hijri year length
  static int getHijriYearLength(int year) {
    return _isHijriLeapYear(year) ? 355 : 354;
  }

  // Format Hijri date
  static String formatHijriDate(HijriDate hijriDate, {
    bool showDayName = true,
    bool isArabic = false,
    String separator = ' ',
  }) {
    final dayName = showDayName 
        ? (isArabic ? hijriDate.dayNameArabic : hijriDate.dayName) + separator
        : '';
    
    final day = hijriDate.day.toString();
    final month = isArabic ? hijriDate.monthNameArabic : hijriDate.monthName;
    final year = hijriDate.year.toString();
    
    if (isArabic) {
      return '$dayName$day $month $year هـ';
    } else {
      return '$dayName$day $month $year AH';
    }
  }

  // Add days to Hijri date
  Future<HijriDate> addDaysToHijri(HijriDate hijriDate, int days) async {
    final gregorianDate = hijriToGregorian(hijriDate.day, hijriDate.month, hijriDate.year);
    final newGregorianDate = gregorianDate.add(Duration(days: days));
    return await gregorianToHijri(newGregorianDate);
  }

  // Subtract days from Hijri date
  Future<HijriDate> subtractDaysFromHijri(HijriDate hijriDate, int days) async {
    final gregorianDate = hijriToGregorian(hijriDate.day, hijriDate.month, hijriDate.year);
    final newGregorianDate = gregorianDate.subtract(Duration(days: days));
    return await gregorianToHijri(newGregorianDate);
  }

  // Get first day of Hijri month
  Future<HijriDate> getFirstDayOfHijriMonth(int month, int year) async {
    final gregorianDate = hijriToGregorian(1, month, year);
    return await gregorianToHijri(gregorianDate);
  }

  // Get last day of Hijri month
  Future<HijriDate> getLastDayOfHijriMonth(int month, int year) async {
    final daysInMonth = getDaysInHijriMonth(month, year);
    final gregorianDate = hijriToGregorian(daysInMonth, month, year);
    return await gregorianToHijri(gregorianDate);
  }

  // Calculate age in Hijri years
  int calculateHijriAge(HijriDate birthDate, HijriDate currentDate) {
    int age = currentDate.year - birthDate.year;
    
    if (currentDate.month < birthDate.month || 
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
}