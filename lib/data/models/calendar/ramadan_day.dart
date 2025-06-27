class RamadanDay {
  final int dayNumber;
  final DateTime date;
  final DateTime suhoorTime;
  final DateTime iftarTime;
  final bool isFasted;
  final String? intention;
  final List<String> specialDua;
  final String? quranReading;
  final String? reflection;

  const RamadanDay({
    required this.dayNumber,
    required this.date,
    required this.suhoorTime,
    required this.iftarTime,
    this.isFasted = false,
    this.intention,
    this.specialDua = const [],
    this.quranReading,
    this.reflection,
  });

  factory RamadanDay.fromJson(Map<String, dynamic> json) {
    return RamadanDay(
      dayNumber: json['dayNumber'],
      date: DateTime.parse(json['date']),
      suhoorTime: DateTime.parse(json['suhoorTime']),
      iftarTime: DateTime.parse(json['iftarTime']),
      isFasted: json['isFasted'] ?? false,
      intention: json['intention'],
      specialDua: List<String>.from(json['specialDua'] ?? []),
      quranReading: json['quranReading'],
      reflection: json['reflection'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'date': date.toIso8601String(),
      'suhoorTime': suhoorTime.toIso8601String(),
      'iftarTime': iftarTime.toIso8601String(),
      'isFasted': isFasted,
      'intention': intention,
      'specialDua': specialDua,
      'quranReading': quranReading,
      'reflection': reflection,
    };
  }
}
