import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithSettingsService {
  static const String _dailyNotificationKey = 'daily_hadith_notification';
  static const String _dailyNotificationTimeKey = 'daily_hadith_time';
  static const String _preferredLanguageKey = 'preferred_language';
  static const String _fontSizeKey = 'hadith_font_size';
  static const String _autoPlayAudioKey = 'auto_play_audio';
  static const String _showTransliterationKey = 'show_transliteration';

  Future<bool> getDailyNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyNotificationKey) ?? true;
  }

  Future<void> setDailyNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyNotificationKey, enabled);
  }

  Future<TimeOfDay> getDailyNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_dailyNotificationTimeKey) ?? '08:00';
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> setDailyNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_dailyNotificationTimeKey, timeString);
  }

  Future<String> getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredLanguageKey) ?? 'en';
  }

  Future<void> setPreferredLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredLanguageKey, language);
  }

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 16.0;
  }

  Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  Future<bool> getAutoPlayAudio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPlayAudioKey) ?? false;
  }

  Future<void> setAutoPlayAudio(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayAudioKey, enabled);
  }

  Future<bool> getShowTransliteration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showTransliterationKey) ?? false;
  }

  Future<void> setShowTransliteration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTransliterationKey, enabled);
  }
}