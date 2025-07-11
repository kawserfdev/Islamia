import 'package:islamia/data/models/user/privacy_settings.dart';

class UserPreferences {
  final String language;
  final String theme; // light, dark, auto
  final NotificationPreferences notifications;
  final AudioPreferences audio;
  final DisplayPreferences display;
  final PrivacyPreferences privacy;
  final LocationPreferences location;
  final BackupPreferences backup;
  final AccessibilityPreferences accessibility;

  const UserPreferences({
    this.language = 'en',
    this.theme = 'auto',
    required this.notifications,
    required this.audio,
    required this.display,
    required this.privacy,
    required this.location,
    required this.backup,
    required this.accessibility,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'auto',
      notifications: NotificationPreferences.fromJson(json['notifications'] ?? {}),
      audio: AudioPreferences.fromJson(json['audio'] ?? {}),
      display: DisplayPreferences.fromJson(json['display'] ?? {}),
      privacy: PrivacyPreferences.fromJson(json['privacy'] ?? {}),
      location: LocationPreferences.fromJson(json['location'] ?? {}),
      backup: BackupPreferences.fromJson(json['backup'] ?? {}),
      accessibility: AccessibilityPreferences.fromJson(json['accessibility'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notifications': notifications.toJson(),
      'audio': audio.toJson(),
      'display': display.toJson(),
      'privacy': privacy.toJson(),
      'location': location.toJson(),
      'backup': backup.toJson(),
      'accessibility': accessibility.toJson(),
    };
  }

  UserPreferences copyWith({
    String? language,
    String? theme,
    NotificationPreferences? notifications,
    AudioPreferences? audio,
    DisplayPreferences? display,
    PrivacyPreferences? privacy,
    LocationPreferences? location,
    BackupPreferences? backup,
    AccessibilityPreferences? accessibility,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      audio: audio ?? this.audio,
      display: display ?? this.display,
      privacy: privacy ?? this.privacy,
      location: location ?? this.location,
      backup: backup ?? this.backup,
      accessibility: accessibility ?? this.accessibility,
    );
  }
}

class NotificationPreferences {
  final bool prayerReminders;
  final bool adhanEnabled;
  final bool islamicEvents;
  final bool readingReminders;
  final bool achievementNotifications;
  final bool communityUpdates;
  final bool marketingEmails;
  final String quietHoursStart;
  final String quietHoursEnd;
  final Map<String, bool> categorySettings;

  const NotificationPreferences({
    this.prayerReminders = true,
    this.adhanEnabled = true,
    this.islamicEvents = true,
    this.readingReminders = true,
    this.achievementNotifications = true,
    this.communityUpdates = false,
    this.marketingEmails = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '06:00',
    this.categorySettings = const {},
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      prayerReminders: json['prayer_reminders'] ?? true,
      adhanEnabled: json['adhan_enabled'] ?? true,
      islamicEvents: json['islamic_events'] ?? true,
      readingReminders: json['reading_reminders'] ?? true,
      achievementNotifications: json['achievement_notifications'] ?? true,
      communityUpdates: json['community_updates'] ?? false,
      marketingEmails: json['marketing_emails'] ?? false,
      quietHoursStart: json['quiet_hours_start'] ?? '22:00',
      quietHoursEnd: json['quiet_hours_end'] ?? '06:00',
      categorySettings: Map<String, bool>.from(json['category_settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prayer_reminders': prayerReminders,
      'adhan_enabled': adhanEnabled,
      'islamic_events': islamicEvents,
      'reading_reminders': readingReminders,
      'achievement_notifications': achievementNotifications,
      'community_updates': communityUpdates,
      'marketing_emails': marketingEmails,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'category_settings': categorySettings,
    };
  }
}

class AudioPreferences {
  final String defaultReciter;
  final double playbackSpeed;
  final double volume;
  final bool autoPlay;
  final bool repeatMode;
  final String audioQuality;
  final bool downloadOverWifiOnly;
  final List<String> favoriteReciters;

  const AudioPreferences({
    this.defaultReciter = 'ar.alafasy',
    this.playbackSpeed = 1.0,
    this.volume = 0.8,
    this.autoPlay = false,
    this.repeatMode = false,
    this.audioQuality = 'medium',
    this.downloadOverWifiOnly = true,
    this.favoriteReciters = const [],
  });

  factory AudioPreferences.fromJson(Map<String, dynamic> json) {
    return AudioPreferences(
      defaultReciter: json['default_reciter'] ?? 'ar.alafasy',
      playbackSpeed: (json['playback_speed'] ?? 1.0).toDouble(),
      volume: (json['volume'] ?? 0.8).toDouble(),
      autoPlay: json['auto_play'] ?? false,
      repeatMode: json['repeat_mode'] ?? false,
      audioQuality: json['audio_quality'] ?? 'medium',
      downloadOverWifiOnly: json['download_over_wifi_only'] ?? true,
      favoriteReciters: List<String>.from(json['favorite_reciters'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default_reciter': defaultReciter,
      'playback_speed': playbackSpeed,
      'volume': volume,
      'auto_play': autoPlay,
      'repeat_mode': repeatMode,
      'audio_quality': audioQuality,
      'download_over_wifi_only': downloadOverWifiOnly,
      'favorite_reciters': favoriteReciters,
    };
  }
}

class DisplayPreferences {
  final double fontSize;
  final String fontFamily;
  final bool showArabicText;
  final bool showTransliteration;
  final bool showTranslation;
  final String primaryLanguage;
  final List<String> enabledTranslations;
  final bool nightMode;
  final bool adaptiveBrightness;
  final String colorScheme;

  const DisplayPreferences({
    this.fontSize = 16.0,
    this.fontFamily = 'Noto Sans',
    this.showArabicText = true,
    this.showTransliteration = false,
    this.showTranslation = true,
    this.primaryLanguage = 'en',
    this.enabledTranslations = const ['en'],
    this.nightMode = false,
    this.adaptiveBrightness = true,
    this.colorScheme = 'default',
  });

  factory DisplayPreferences.fromJson(Map<String, dynamic> json) {
    return DisplayPreferences(
      fontSize: (json['font_size'] ?? 16.0).toDouble(),
      fontFamily: json['font_family'] ?? 'Noto Sans',
      showArabicText: json['show_arabic_text'] ?? true,
      showTransliteration: json['show_transliteration'] ?? false,
      showTranslation: json['show_translation'] ?? true,
      primaryLanguage: json['primary_language'] ?? 'en',
      enabledTranslations: List<String>.from(json['enabled_translations'] ?? ['en']),
      nightMode: json['night_mode'] ?? false,
      adaptiveBrightness: json['adaptive_brightness'] ?? true,
      colorScheme: json['color_scheme'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'font_size': fontSize,
      'font_family': fontFamily,
      'show_arabic_text': showArabicText,
      'show_transliteration': showTransliteration,
      'show_translation': showTranslation,
      'primary_language': primaryLanguage,
      'enabled_translations': enabledTranslations,
      'night_mode': nightMode,
      'adaptive_brightness': adaptiveBrightness,
      'color_scheme': colorScheme,
    };
  }
}

class PrivacyPreferences {
  final bool profileVisible;
  final bool statisticsVisible;
  final bool achievementsVisible;
  final bool locationSharing;
  final bool activityTracking;
  final bool crashReporting;
  final bool analyticsEnabled;
  final bool personalizedAds;
  final DataRetentionPeriod dataRetention;

  const PrivacyPreferences({
    this.profileVisible = true,
    this.statisticsVisible = true,
    this.achievementsVisible = true,
    this.locationSharing = false,
    this.activityTracking = true,
    this.crashReporting = true,
    this.analyticsEnabled = true,
    this.personalizedAds = false,
    this.dataRetention = DataRetentionPeriod.oneYear,
  });

  factory PrivacyPreferences.fromJson(Map<String, dynamic> json) {
    return PrivacyPreferences(
      profileVisible: json['profile_visible'] ?? true,
      statisticsVisible: json['statistics_visible'] ?? true,
      achievementsVisible: json['achievements_visible'] ?? true,
       locationSharing: json['location_sharing'] ?? false,
      activityTracking: json['activity_tracking'] ?? true,
      crashReporting: json['crash_reporting'] ?? true,
      analyticsEnabled: json['analytics_enabled'] ?? true,
      personalizedAds: json['personalized_ads'] ?? false,
      dataRetention: DataRetentionPeriod.values.firstWhere(
        (e) => e.name == json['data_retention'],
        orElse: () => DataRetentionPeriod.oneYear,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_visible': profileVisible,
      'statistics_visible': statisticsVisible,
      'achievements_visible': achievementsVisible,
      'location_sharing': locationSharing,
      'activity_tracking': activityTracking,
      'crash_reporting': crashReporting,
      'analytics_enabled': analyticsEnabled,
      'personalized_ads': personalizedAds,
      'data_retention': dataRetention.name,
    };
  }
}

class LocationPreferences {
  final bool enableLocationServices;
  final bool highAccuracyMode;
  final bool autoDetectTimeZone;
  final bool backgroundLocationUpdates;
  final int locationUpdateInterval; // in minutes
  final bool shareLocationWithMosques;

  const LocationPreferences({
    this.enableLocationServices = true,
    this.highAccuracyMode = false,
    this.autoDetectTimeZone = true,
    this.backgroundLocationUpdates = false,
    this.locationUpdateInterval = 30,
    this.shareLocationWithMosques = false,
  });

  factory LocationPreferences.fromJson(Map<String, dynamic> json) {
    return LocationPreferences(
      enableLocationServices: json['enable_location_services'] ?? true,
      highAccuracyMode: json['high_accuracy_mode'] ?? false,
      autoDetectTimeZone: json['auto_detect_time_zone'] ?? true,
      backgroundLocationUpdates: json['background_location_updates'] ?? false,
      locationUpdateInterval: json['location_update_interval'] ?? 30,
      shareLocationWithMosques: json['share_location_with_mosques'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_location_services': enableLocationServices,
      'high_accuracy_mode': highAccuracyMode,
      'auto_detect_time_zone': autoDetectTimeZone,
      'background_location_updates': backgroundLocationUpdates,
      'location_update_interval': locationUpdateInterval,
      'share_location_with_mosques': shareLocationWithMosques,
    };
  }
}

class BackupPreferences {
  final bool autoBackup;
  final BackupFrequency backupFrequency;
  final bool backupOverWifiOnly;
  final bool includeAudioFiles;
  final bool encryptBackups;
  final DateTime? lastBackupDate;
  final String backupLocation; // cloud, local

  const BackupPreferences({
    this.autoBackup = true,
    this.backupFrequency = BackupFrequency.weekly,
    this.backupOverWifiOnly = true,
    this.includeAudioFiles = false,
    this.encryptBackups = true,
    this.lastBackupDate,
    this.backupLocation = 'cloud',
  });

  factory BackupPreferences.fromJson(Map<String, dynamic> json) {
    return BackupPreferences(
      autoBackup: json['auto_backup'] ?? true,
      backupFrequency: BackupFrequency.values.firstWhere(
        (e) => e.name == json['backup_frequency'],
        orElse: () => BackupFrequency.weekly,
      ),
      backupOverWifiOnly: json['backup_over_wifi_only'] ?? true,
      includeAudioFiles: json['include_audio_files'] ?? false,
      encryptBackups: json['encrypt_backups'] ?? true,
      lastBackupDate: json['last_backup_date'] != null 
          ? DateTime.parse(json['last_backup_date'])
          : null,
      backupLocation: json['backup_location'] ?? 'cloud',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_backup': autoBackup,
      'backup_frequency': backupFrequency.name,
      'backup_over_wifi_only': backupOverWifiOnly,
      'include_audio_files': includeAudioFiles,
      'encrypt_backups': encryptBackups,
      'last_backup_date': lastBackupDate?.toIso8601String(),
      'backup_location': backupLocation,
    };
  }
}

class AccessibilityPreferences {
  final bool screenReader;
  final bool highContrast;
  final bool largeText;
  final bool reduceMotion;
  final bool hapticFeedback;
  final bool voiceCommands;
  final double textScaleFactor;
  final bool colorInversion;

  const AccessibilityPreferences({
    this.screenReader = false,
    this.highContrast = false,
    this.largeText = false,
    this.reduceMotion = false,
    this.hapticFeedback = true,
    this.voiceCommands = false,
    this.textScaleFactor = 1.0,
    this.colorInversion = false,
  });

  factory AccessibilityPreferences.fromJson(Map<String, dynamic> json) {
    return AccessibilityPreferences(
      screenReader: json['screen_reader'] ?? false,
      highContrast: json['high_contrast'] ?? false,
      largeText: json['large_text'] ?? false,
      reduceMotion: json['reduce_motion'] ?? false,
      hapticFeedback: json['haptic_feedback'] ?? true,
      voiceCommands: json['voice_commands'] ?? false,
      textScaleFactor: (json['text_scale_factor'] ?? 1.0).toDouble(),
      colorInversion: json['color_inversion'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screen_reader': screenReader,
      'high_contrast': highContrast,
      'large_text': largeText,
      'reduce_motion': reduceMotion,
      'haptic_feedback': hapticFeedback,
      'voice_commands': voiceCommands,
      'text_scale_factor': textScaleFactor,
      'color_inversion': colorInversion,
    };
  }
}
