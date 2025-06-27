class CompassReading {
  final double heading;
  final double accuracy;
  final DateTime timestamp;
  final bool isCalibrated;
  final double magneticDeclination;

  const CompassReading({
    required this.heading,
    required this.accuracy,
    required this.timestamp,
    this.isCalibrated = false,
    this.magneticDeclination = 0.0,
  });

  factory CompassReading.fromJson(Map<String, dynamic> json) {
    return CompassReading(
      heading: json['heading'].toDouble(),
      accuracy: json['accuracy'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      isCalibrated: json['isCalibrated'] ?? false,
      magneticDeclination: (json['magneticDeclination'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'isCalibrated': isCalibrated,
      'magneticDeclination': magneticDeclination,
    };
  }

  double get trueHeading => heading + magneticDeclination;
}