import 'package:islamia/data/models/calendar/islamic_event.dart';

class IslamicDate {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String monthNameArabic;
  final bool isLeapYear;
  final int dayOfWeek;
  final String dayName;
  final List<IslamicEvent> events;

  const IslamicDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.monthNameArabic,
    required this.isLeapYear,
    required this.dayOfWeek,
    required this.dayName,
    this.events = const [],
  });

  factory IslamicDate.fromJson(Map<String, dynamic> json) {
    return IslamicDate(
      day: json['day'],
      month: json['month'],
      year: json['year'],
      monthName: json['monthName'],
      monthNameArabic: json['monthNameArabic'],
      isLeapYear: json['isLeapYear'],
      dayOfWeek: json['dayOfWeek'],
      dayName: json['dayName'],
      events: (json['events'] as List?)?.map((e) => IslamicEvent.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'monthName': monthName,
      'monthNameArabic': monthNameArabic,
      'isLeapYear': isLeapYear,
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  String get formattedDate => '$day $monthName $year';
  String get formattedDateArabic => '$day $monthNameArabic $year';

  static const List<String> monthNames = [
    'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
    'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
  ];

  static const List<String> monthNamesArabic = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];
}