import 'package:shared_preferences/shared_preferences.dart';

class QuranSettingsService {
  static const String _arabicFontSizeKey = 'quran_arabic_font_size';
  static const String _translationFontSizeKey = 'quran_translation_font_size';
  static const String _selectedTranslationKey = 'quran_selected_translation';
  static const String _showTransliterationKey = 'quran_show_transliteration';
  static const String _nightModeKey = 'quran_night_mode';
  static const String _showTafsirKey = 'quran_show_tafsir';
  static const String _fontFamilyKey = 'quran_font_family';
  static const String _dualColumnLayoutKey = 'quran_dual_column_layout';
  static const String _selectedReciterKey = 'quran_selected_reciter';
  static const String _autoScrollKey = 'quran_auto_scroll';
  static const String _highlightCurrentAyahKey = 'quran_highlight_current_ayah';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('QuranSettingsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Font Settings
  Future<void> setArabicFontSize(double size) async {
    await prefs.setDouble(_arabicFontSizeKey, size);
  }

  double getArabicFontSize() {
    return prefs.getDouble(_arabicFontSizeKey) ?? 24.0;
  }

  Future<void> setTranslationFontSize(double size) async {
    await prefs.setDouble(_translationFontSizeKey, size);
  }

  double getTranslationFontSize() {
    return prefs.getDouble(_translationFontSizeKey) ?? 16.0;
  }

  Future<void> setFontFamily(String fontFamily) async {
    await prefs.setString(_fontFamilyKey, fontFamily);
  }

  String getFontFamily() {
    return prefs.getString(_fontFamilyKey) ?? 'UthmanicHafs';
  }

  // Translation Settings
  Future<void> setSelectedTranslation(String translation) async {
    await prefs.setString(_selectedTranslationKey, translation);
  }

  String getSelectedTranslation() {
    return prefs.getString(_selectedTranslationKey) ?? 'en.sahih';
  }

  Future<void> setShowTransliteration(bool show) async {
    await prefs.setBool(_showTransliterationKey, show);
  }

  bool getShowTransliteration() {
    return prefs.getBool(_showTransliterationKey) ?? false;
  }

  // Display Settings
  Future<void> setNightMode(bool enabled) async {
    await prefs.setBool(_nightModeKey, enabled);
  }

  bool getNightMode() {
    return prefs.getBool(_nightModeKey) ?? false;
  }

  Future<void> setDualColumnLayout(bool enabled) async {
    await prefs.setBool(_dualColumnLayoutKey, enabled);
  }

  bool getDualColumnLayout() {
    return prefs.getBool(_dualColumnLayoutKey) ?? false;
  }

  Future<void> setShowTafsir(bool show) async {
    await prefs.setBool(_showTafsirKey, show);
  }

  bool getShowTafsir() {
    return prefs.getBool(_showTafsirKey) ?? false;
  }

  // Audio Settings
  Future<void> setSelectedReciter(String reciter) async {
    await prefs.setString(_selectedReciterKey, reciter);
  }

  String getSelectedReciter() {
    return prefs.getString(_selectedReciterKey) ?? 'ar.alafasy';
  }

  // Reading Settings
  Future<void> setAutoScroll(bool enabled) async {
    await prefs.setBool(_autoScrollKey, enabled);
  }

  bool getAutoScroll() {
    return prefs.getBool(_autoScrollKey) ?? false;
  }

  Future<void> setHighlightCurrentAyah(bool enabled) async {
    await prefs.setBool(_highlightCurrentAyahKey, enabled);
  }

  bool getHighlightCurrentAyah() {
    return prefs.getBool(_highlightCurrentAyahKey) ?? true;
  }

  // Reset Settings
  Future<void> resetToDefaults() async {
    await prefs.remove(_arabicFontSizeKey);
    await prefs.remove(_translationFontSizeKey);
    await prefs.remove(_selectedTranslationKey);
    await prefs.remove(_showTransliterationKey);
    await prefs.remove(_nightModeKey);
    await prefs.remove(_showTafsirKey);
    await prefs.remove(_fontFamilyKey);
    await prefs.remove(_dualColumnLayoutKey);
    await prefs.remove(_selectedReciterKey);
    await prefs.remove(_autoScrollKey);
    await prefs.remove(_highlightCurrentAyahKey);
  }

  // Export/Import Settings
  Map<String, dynamic> exportSettings() {
    return {
      'arabicFontSize': getArabicFontSize(),
      'translationFontSize': getTranslationFontSize(),
      'selectedTranslation': getSelectedTranslation(),
      'showTransliteration': getShowTransliteration(),
      'nightMode': getNightMode(),
      'showTafsir': getShowTafsir(),
      'fontFamily': getFontFamily(),
      'dualColumnLayout': getDualColumnLayout(),
      'selectedReciter': getSelectedReciter(),
      'autoScroll': getAutoScroll(),
      'highlightCurrentAyah': getHighlightCurrentAyah(),
    };
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings['arabicFontSize'] != null) {
      await setArabicFontSize(settings['arabicFontSize']);
    }
    if (settings['translationFontSize'] != null) {
      await setTranslationFontSize(settings['translationFontSize']);
    }
    if (settings['selectedTranslation'] != null) {
      await setSelectedTranslation(settings['selectedTranslation']);
    }
    if (settings['showTransliteration'] != null) {
      await setShowTransliteration(settings['showTransliteration']);
    }
    if (settings['nightMode'] != null) {
      await setNightMode(settings['nightMode']);
    }
    if (settings['showTafsir'] != null) {
      await setShowTafsir(settings['showTafsir']);
    }
    if (settings['fontFamily'] != null) {
      await setFontFamily(settings['fontFamily']);
    }
    if (settings['dualColumnLayout'] != null) {
      await setDualColumnLayout(settings['dualColumnLayout']);
    }
    if (settings['selectedReciter'] != null) {
      await setSelectedReciter(settings['selectedReciter']);
    }
    if (settings['autoScroll'] != null) {
      await setAutoScroll(settings['autoScroll']);
    }
    if (settings['highlightCurrentAyah'] != null) {
      await setHighlightCurrentAyah(settings['highlightCurrentAyah']);
    }
  }
}