
class HijriDate {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String monthNameArabic;
  final String dayName;
  final String dayNameArabic;
  final bool isLeapYear;
  final int weekDay;

  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.monthNameArabic,
    required this.dayName,
    required this.dayNameArabic,
    required this.isLeapYear,
    required this.weekDay,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      day: json['day'],
      month: json['month'],
      year: json['year'],
      monthName: json['monthName'],
      monthNameArabic: json['monthNameArabic'],
      dayName: json['dayName'],
      dayNameArabic: json['dayNameArabic'],
      isLeapYear: json['isLeapYear'] ?? false,
      weekDay: json['weekDay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'monthName': monthName,
      'monthNameArabic': monthNameArabic,
      'dayName': dayName,
      'dayNameArabic': dayNameArabic,
      'isLeapYear': isLeapYear,
      'weekDay': weekDay,
    };
  }

  Map<String, dynamic> toSQLiteMap() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'month_name': monthName,
      'month_name_arabic': monthNameArabic,
      'day_name': dayName,
      'day_name_arabic': dayNameArabic,
      'is_leap_year': isLeapYear ? 1 : 0,
      'week_day': weekDay,
    };
  }

  factory HijriDate.fromSQLiteMap(Map<String, dynamic> map) {
    return HijriDate(
      day: map['day'],
      month: map['month'],
      year: map['year'],
      monthName: map['month_name'],
      monthNameArabic: map['month_name_arabic'],
      dayName: map['day_name'],
      dayNameArabic: map['day_name_arabic'],
      isLeapYear: map['is_leap_year'] == 1,
      weekDay: map['week_day'],
    );
  }

  String get formattedDate => '$day $monthName $year';
  String get formattedDateArabic => '$day $monthNameArabic $year';
  String get shortFormat => '$day/$month/$year';

  HijriDate copyWith({
    int? day,
    int? month,
    int? year,
    String? monthName,
    String? monthNameArabic,
    String? dayName,
    String? dayNameArabic,
    bool? isLeapYear,
    int? weekDay,
  }) {
    return HijriDate(
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      monthName: monthName ?? this.monthName,
      monthNameArabic: monthNameArabic ?? this.monthNameArabic,
      dayName: dayName ?? this.dayName,
      dayNameArabic: dayNameArabic ?? this.dayNameArabic,
      isLeapYear: isLeapYear ?? this.isLeapYear,
      weekDay: weekDay ?? this.weekDay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HijriDate &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => day.hashCode ^ month.hashCode ^ year.hashCode;

  @override
  String toString() => 'HijriDate($day $monthName $year)';
}
