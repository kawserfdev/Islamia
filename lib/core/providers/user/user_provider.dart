import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamia/core/database/user_database.dart';
import 'package:islamia/core/services/auth/auth_service.dart';
import 'package:islamia/core/services/cloud_sync_service.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) => CloudSyncService());
final userDatabaseProvider = Provider<UserDatabase>((ref) => UserDatabase());

// Authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// Current user profile
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getCurrentUserProfile();
});

// Authentication notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserProfile? user;
  final String? error;
  final bool isEmailVerified;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserProfile? user,
    String? error,
    bool? isEmailVerified,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final profile = await _authService.getCurrentUserProfile();
      if (profile != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: profile,
          isEmailVerified: _authService.currentUser?.emailVerified ?? false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isEmailVerified: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isEmailVerified: _authService.currentUser?.emailVerified ?? false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithGoogle();

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isEmailVerified: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithPhone(phoneNumber);

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isEmailVerified: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> signInAsGuest() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInAsGuest();

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isEmailVerified: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> signInWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithBiometrics();

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isEmailVerified: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.sendPasswordResetEmail(email);

    state = state.copyWith(
      isLoading: false,
      error: result.isSuccess ? null : result.error,
    );
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.updateUserProfile(updatedProfile);

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        user: result.user,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    await _authService.signOut();
    
    state = const AuthState();
  }

  Future<void> deleteAccount(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.deleteAccount(password);

    if (result.isSuccess) {
      state = const AuthState();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// User statistics provider
final userStatisticsProvider = FutureProvider.family<UserStatistics, String>((ref, userId) async {
  final database = ref.read(userDatabaseProvider);
  final prayerStats = await database.getPrayerStatistics(userId);
  final readingStats = await database.getReadingStatistics(userId);
  
  return UserStatistics(
    prayerStats: prayerStats,
    readingStats: readingStats,
    // Add other statistics here
  );
});

// User achievements provider
final userAchievementsProvider = FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final database = ref.read(userDatabaseProvider);
  return await database.getUserAchievements(userId);
});

// Settings provider
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserPreferences?>((ref) {
  return UserSettingsNotifier(
    ref.read(authServiceProvider),
    ref.read(cloudSyncServiceProvider),
  );
});

class UserSettingsNotifier extends StateNotifier<UserPreferences?> {
  final AuthService _authService;
  final CloudSyncService _cloudSync;

  UserSettingsNotifier(this._authService, this._cloudSync) : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final profile = await _authService.getCurrentUserProfile();
    if (profile != null) {
      state = profile.preferences;
    }
  }

  Future<void> updateLanguage(String language) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(language: language);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updateTheme(String theme) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(theme: theme);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updateNotificationPreferences(NotificationPreferences notifications) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(notifications: notifications);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updateAudioPreferences(AudioPreferences audio) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(audio: audio);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updateDisplayPreferences(DisplayPreferences display) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(display: display);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updatePrivacyPreferences(PrivacyPreferences privacy) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(privacy: privacy);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updateLocationPreferences(LocationPreferences location) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(location: location);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updateBackupPreferences(BackupPreferences backup) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(backup: backup);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> updateAccessibilityPreferences(AccessibilityPreferences accessibility) async {
    if (state == null) return;
    
    final updatedPreferences = state!.copyWith(accessibility: accessibility);
    await _updatePreferences(updatedPreferences);
  }

  Future<void> _updatePreferences(UserPreferences preferences) async {
    state = preferences;
    
    // Update user profile
    final profile = await _authService.getCurrentUserProfile();
    if (profile != null) {
      final updatedProfile = profile.copyWith(
        preferences: preferences,
        updatedAt: DateTime.now(),
      );
      await _authService.updateUserProfile(updatedProfile);
    }
  }
}

// Backup provider
final backupProvider = StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier(ref.read(cloudSyncServiceProvider));
});

class BackupState {
  final bool isLoading;
  final List<Map<String, dynamic>> backups;
  final String? error;
  final DateTime? lastBackup;

  const BackupState({
    this.isLoading = false,
    this.backups = const [],
    this.error,
    this.lastBackup,
  });

  BackupState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? backups,
    String? error,
    DateTime? lastBackup,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      backups: backups ?? this.backups,
      error: error,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }
}

class BackupNotifier extends StateNotifier<BackupState> {
  final CloudSyncService _cloudSync;

  BackupNotifier(this._cloudSync) : super(const BackupState());

  Future<void> loadBackups(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final backups = await _cloudSync.getUserBackups(userId);
      state = state.copyWith(
        isLoading: false,
        backups: backups,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createBackup(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _cloudSync.createBackup(userId);
      
      // Reload backups
      await loadBackups(userId);
      
      state = state.copyWith(
        lastBackup: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> restoreBackup(String userId, String backupId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _cloudSync.restoreFromBackup(userId, backupId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return ThemeNotifier(settings?.theme ?? 'auto');
});

class ThemeState {
  final String theme; // light, dark, auto
  final bool isDarkMode;

  const ThemeState({
    required this.theme,
    required this.isDarkMode,
  });

  ThemeState copyWith({
    String? theme,
    bool? isDarkMode,
  }) {
    return ThemeState(
      theme: theme ?? this.theme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier(String initialTheme) : super(ThemeState(
    theme: initialTheme,
    isDarkMode: _calculateDarkMode(initialTheme),
  ));

  void updateTheme(String theme) {
    state = state.copyWith(
      theme: theme,
      isDarkMode: _calculateDarkMode(theme),
    );
  }

  static bool _calculateDarkMode(String theme) {
    switch (theme) {
      case 'light':
        return false;
      case 'dark':
        return true;
      case 'auto':
      default:
        // You would check system theme here
        return false; // Default to light
    }
  }
}

// Language provider
final languageProvider = StateProvider<String>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings?.language ?? 'en';
});

// Prayer tracking provider
final prayerTrackingProvider = StateNotifierProvider<PrayerTrackingNotifier, PrayerTrackingState>((ref) {
  return PrayerTrackingNotifier(ref.read(userDatabaseProvider));
});

class PrayerTrackingState {
  final bool isLoading;
  final PrayerStatistics? statistics;
  final String? error;

  const PrayerTrackingState({
    this.isLoading = false,
    this.statistics,
    this.error,
  });

  PrayerTrackingState copyWith({
    bool? isLoading,
    PrayerStatistics? statistics,
    String? error,
  }) {
    return PrayerTrackingState(
      isLoading: isLoading ?? this.isLoading,
      statistics: statistics ?? this.statistics,
      error: error,
    );
  }
}

class PrayerTrackingNotifier extends StateNotifier<PrayerTrackingState> {
  final UserDatabase _database;

  PrayerTrackingNotifier(this._database) : super(const PrayerTrackingState());

  Future<void> loadStatistics(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final stats = await _database.getPrayerStatistics(userId);
      state = state.copyWith(
        isLoading: false,
        statistics: stats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logPrayer({
    required String userId,
    required String prayerName,
    required DateTime prayerTime,
    required DateTime actualTime,
    String? location,
    String? notes,
  }) async {
    try {
      await _database.logPrayer(
        userId: userId,
        prayerName: prayerName,
        prayerTime: prayerTime,
        actualTime: actualTime,
        location: location,
        notes: notes,
      );
      
      // Reload statistics
      await loadStatistics(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}