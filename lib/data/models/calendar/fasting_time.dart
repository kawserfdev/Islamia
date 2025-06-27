class FastingTime {
  final DateTime suhoorTime;
  final DateTime iftarTime;
  final Duration fastingDuration;

  const FastingTime({
    required this.suhoorTime,
    required this.iftarTime,
    required this.fastingDuration,
  });

  factory FastingTime.fromJson(Map<String, dynamic> json) {
    return FastingTime(
      suhoorTime: DateTime.parse(json['suhoorTime']),
      iftarTime: DateTime.parse(json['iftarTime']),
      fastingDuration: Duration(milliseconds: json['fastingDurationMs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suhoorTime': suhoorTime.toIso8601String(),
      'iftarTime': iftarTime.toIso8601String(),
      'fastingDurationMs': fastingDuration.inMilliseconds,
    };
  }
}