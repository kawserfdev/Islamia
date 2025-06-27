class AppSettings {
  final String version;
  final String buildNumber;
  final bool isFirstLaunch;
  final DateTime? lastSyncTime;
  final String? deviceId;
  final String? fcmToken;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final Map<String, dynamic> featureFlags;

  const AppSettings({
    required this.version,
    required this.buildNumber,
    this.isFirstLaunch = true,
    this.lastSyncTime,
    this.deviceId,
    this.fcmToken,
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.featureFlags = const {},
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      version: json['version'],
      buildNumber: json['buildNumber'],
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      lastSyncTime: json['lastSyncTime'] != null ? DateTime.parse(json['lastSyncTime']) : null,
      deviceId: json['deviceId'],
      fcmToken: json['fcmToken'],
      analyticsEnabled: json['analyticsEnabled'] ?? true,
      crashReportingEnabled: json['crashReportingEnabled'] ?? true,
      featureFlags: Map<String, dynamic>.from(json['featureFlags'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildNumber': buildNumber,
      'isFirstLaunch': isFirstLaunch,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'deviceId': deviceId,
      'fcmToken': fcmToken,
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'featureFlags': featureFlags,
    };
  }
}