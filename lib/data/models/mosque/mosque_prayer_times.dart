class MosquePrayerTimes {
  final String mosqueId;
  final DateTime date;
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime? jumma;
  final Map<String, int> adjustments;
  final bool isCustomTiming;
  final String? notes;

  const MosquePrayerTimes({
    required this.mosqueId,
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.jumma,
    this.adjustments = const {},
    this.isCustomTiming = false,
    this.notes,
  });

  factory MosquePrayerTimes.fromJson(Map<String, dynamic> json) {
    return MosquePrayerTimes(
      mosqueId: json['mosqueId'],
      date: DateTime.parse(json['date']),
      fajr: DateTime.parse(json['fajr']),
      dhuhr: DateTime.parse(json['dhuhr']),
      asr: DateTime.parse(json['asr']),
      maghrib: DateTime.parse(json['maghrib']),
      isha: DateTime.parse(json['isha']),
      jumma: json['jumma'] != null ? DateTime.parse(json['jumma']) : null,
      adjustments: Map<String, int>.from(json['adjustments'] ?? {}),
      isCustomTiming: json['isCustomTiming'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mosqueId': mosqueId,
      'date': date.toIso8601String(),
      'fajr': fajr.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'jumma': jumma?.toIso8601String(),
      'adjustments': adjustments,
      'isCustomTiming': isCustomTiming,
      'notes': notes,
    };
  }
}
