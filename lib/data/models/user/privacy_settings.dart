class PrivacySettings {
  final bool isProfilePublic;
  final bool allowFriendRequests;
  final bool showOnlineStatus;
  final bool allowMessageFromStrangers;
  final bool shareReadingProgress;
  final bool sharePrayerStats;
  final List<String> blockedUsers;
  final DataSharingLevel dataSharingLevel;
  final bool gdprCompliance;
  final DateTime? lastPrivacyUpdate;

  const PrivacySettings({
    this.isProfilePublic = false,
    this.allowFriendRequests = true,
    this.showOnlineStatus = false,
    this.allowMessageFromStrangers = false,
    this.shareReadingProgress = false,
    this.sharePrayerStats = false,
    this.blockedUsers = const [],
    this.dataSharingLevel = DataSharingLevel.minimal,
    this.gdprCompliance = true,
    this.lastPrivacyUpdate,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      isProfilePublic: json['is_profile_public'] ?? false,
      allowFriendRequests: json['allow_friend_requests'] ?? true,
      showOnlineStatus: json['show_online_status'] ?? false,
      allowMessageFromStrangers: json['allow_message_from_strangers'] ?? false,
      shareReadingProgress: json['share_reading_progress'] ?? false,
      sharePrayerStats: json['share_prayer_stats'] ?? false,
      blockedUsers: List<String>.from(json['blocked_users'] ?? []),
      dataSharingLevel: DataSharingLevel.values.firstWhere(
        (e) => e.name == json['data_sharing_level'],
        orElse: () => DataSharingLevel.minimal,
      ),
      gdprCompliance: json['gdpr_compliance'] ?? true,
      lastPrivacyUpdate: json['last_privacy_update'] != null 
          ? DateTime.parse(json['last_privacy_update'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_profile_public': isProfilePublic,
      'allow_friend_requests': allowFriendRequests,
      'show_online_status': showOnlineStatus,
      'allow_message_from_strangers': allowMessageFromStrangers,
      'share_reading_progress': shareReadingProgress,
      'share_prayer_stats': sharePrayerStats,
      'blocked_users': blockedUsers,
      'data_sharing_level': dataSharingLevel.name,
      'gdpr_compliance': gdprCompliance,
      'last_privacy_update': lastPrivacyUpdate?.toIso8601String(),
    };
  }
}

enum DataRetentionPeriod {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  twoYears,
  indefinite,
}

enum BackupFrequency {
  daily,
  weekly,
  monthly,
  manual,
}

enum DataSharingLevel {
  none,
  minimal,
  standard,
  full,
}