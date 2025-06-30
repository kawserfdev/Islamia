import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/quran/settings_service.dart';
import 'package:islamia/core/services/quran/initialization_service.dart'; // Added
import 'package:flutter/scheduler.dart'; // Added for WidgetsBinding / SchedulerBinding

final quranSettingsServiceProvider = Provider<QuranSettingsService>((ref) {
  // This service instance is created and its init() is called by quranServicesInitializationProvider.
  // It's important that QuranSettingsService() itself doesn't do async work in constructor.
  return QuranSettingsService();
});

final quranSettingsProvider =
    StateNotifierProvider<QuranSettingsNotifier, QuranSettings>((ref) {
  final settingsService = ref.read(quranSettingsServiceProvider);
  final notifier = QuranSettingsNotifier(settingsService);

  // Listen to the quranServicesInitializationProvider's state changes
  ref.listen<AsyncValue<bool>>(quranServicesInitializationProvider, (previous, next) {
    next.whenData((initializedSuccessfully) {
      if (initializedSuccessfully) {
        // Call loadInitialSettings on the notifier.
        // This is safe because loadInitialSettings is async and handles its own state update.
        notifier.loadInitialSettings();
      }
      // No explicit error handling here for quranServicesInitializationProvider failure,
      // as SplashScreen should prevent navigation, and settings would remain default.
    });
  });

  // Also check the current state of the initialization provider when this provider is first built.
  // This handles the case where quranServicesInitializationProvider completed *before*
  // quranSettingsProvider was first watched/read.
  final currentInitState = ref.watch(quranServicesInitializationProvider);
  if (currentInitState.hasValue && currentInitState.value == true) {
    // Using SchedulerBinding.instance.addPostFrameCallback to ensure that
    // loadInitialSettings (which might update state) is called after the current build cycle.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Check if the provider is still mounted before calling, as the widget
      // that first triggered this provider might have been disposed.
      if (ref.mounted) {
        notifier.loadInitialSettings();
      }
    });
  }

  return notifier;
});


class QuranSettings {
  final double arabicFontSize;
  final double translationFontSize;
  final String selectedTranslation;
  final bool showTransliteration;
  final bool nightMode;
  final bool showTafsir;
  final String fontFamily;
  final bool dualColumnLayout;
  final String selectedReciter;
  final bool autoScroll;
  final bool highlightCurrentAyah;

  const QuranSettings({
    this.arabicFontSize = 24.0,
    this.translationFontSize = 16.0,
    this.selectedTranslation = 'en.sahih',
    this.showTransliteration = false,
    this.nightMode = false,
    this.showTafsir = false,
    this.fontFamily = 'UthmanicHafs',
    this.dualColumnLayout = false,
    this.selectedReciter = 'ar.alafasy',
    this.autoScroll = false,
    this.highlightCurrentAyah = true,
  });

  QuranSettings copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    String? selectedTranslation,
    bool? showTransliteration,
    bool? nightMode,
    bool? showTafsir,
    String? fontFamily,
    bool? dualColumnLayout,
    String? selectedReciter,
    bool? autoScroll,
    bool? highlightCurrentAyah,
  }) {
    return QuranSettings(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      selectedTranslation: selectedTranslation ?? this.selectedTranslation,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      nightMode: nightMode ?? this.nightMode,
      showTafsir: showTafsir ?? this.showTafsir,
      fontFamily: fontFamily ?? this.fontFamily,
      dualColumnLayout: dualColumnLayout ?? this.dualColumnLayout,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      autoScroll: autoScroll ?? this.autoScroll,
      highlightCurrentAyah: highlightCurrentAyah ?? this.highlightCurrentAyah,
    );
  }
}

class QuranSettingsNotifier extends StateNotifier<QuranSettings> {
  final QuranSettingsService _settingsService;
  bool _initialSettingsLoaded = false;

  QuranSettingsNotifier(this._settingsService) : super(const QuranSettings());
  // _loadSettings() call removed from constructor

  Future<void> loadInitialSettings() async {
    if (_initialSettingsLoaded) return; // Guard to prevent multiple loads

    try {
      // This is the logic from the original _loadSettings
      state = QuranSettings(
        arabicFontSize: _settingsService.getArabicFontSize(),
        translationFontSize: _settingsService.getTranslationFontSize(),
        selectedTranslation: _settingsService.getSelectedTranslation(),
        showTransliteration: _settingsService.getShowTransliteration(),
        nightMode: _settingsService.getNightMode(),
        showTafsir: _settingsService.getShowTafsir(),
        fontFamily: _settingsService.getFontFamily(),
        dualColumnLayout: _settingsService.getDualColumnLayout(),
        selectedReciter: _settingsService.getSelectedReciter(),
        autoScroll: _settingsService.getAutoScroll(),
        highlightCurrentAyah: _settingsService.getHighlightCurrentAyah(),
      );
      _initialSettingsLoaded = true; // Mark as loaded
    } catch (e) {
      print("Error in QuranSettingsNotifier.loadInitialSettings: $e");
    }
  }

  Color getBackgroundColor(QuranSettings settings) =>
    settings.nightMode ? Colors.black : Colors.white;


  Future<void> setArabicFontSize(double size) async {
    await _settingsService.setArabicFontSize(size);
    state = state.copyWith(arabicFontSize: size);
  }

  Future<void> setTranslationFontSize(double size) async {
    await _settingsService.setTranslationFontSize(size);
    state = state.copyWith(translationFontSize: size);
  }

  Future<void> setSelectedTranslation(String translation) async {
    await _settingsService.setSelectedTranslation(translation);
    state = state.copyWith(selectedTranslation: translation);
  }

  Future<void> setShowTransliteration(bool show) async {
    await _settingsService.setShowTransliteration(show);
    state = state.copyWith(showTransliteration: show);
  }

  Future<void> setNightMode(bool enabled) async {
    await _settingsService.setNightMode(enabled);
    state = state.copyWith(nightMode: enabled);
  }

  Future<void> setShowTafsir(bool show) async {
    await _settingsService.setShowTafsir(show);
    state = state.copyWith(showTafsir: show);
  }

  Future<void> setFontFamily(String fontFamily) async {
    await _settingsService.setFontFamily(fontFamily);
    state = state.copyWith(fontFamily: fontFamily);
  }

  Future<void> setDualColumnLayout(bool enabled) async {
    await _settingsService.setDualColumnLayout(enabled);
    state = state.copyWith(dualColumnLayout: enabled);
  }

  Future<void> setSelectedReciter(String reciter) async {
    await _settingsService.setSelectedReciter(reciter);
    state = state.copyWith(selectedReciter: reciter);
  }

  Future<void> setAutoScroll(bool enabled) async {
    await _settingsService.setAutoScroll(enabled);
    state = state.copyWith(autoScroll: enabled);
  }

  Future<void> setHighlightCurrentAyah(bool enabled) async {
    await _settingsService.setHighlightCurrentAyah(enabled);
    state = state.copyWith(highlightCurrentAyah: enabled);
  }

  Future<void> resetToDefaults() async {
    await _settingsService.resetToDefaults();
    _initialSettingsLoaded = false; // Allow re-load
    await loadInitialSettings(); // Reload to ensure state matches service defaults
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    await _settingsService.importSettings(settings);
    _initialSettingsLoaded = false; // Reset flag to allow reloading fresh data
    await loadInitialSettings(); // This will read all settings from the service again
  }

  Map<String, dynamic> exportSettings() {
    return _settingsService.exportSettings();
  }
}