class AppConstants {
  static const String appName = 'Islamia';
  static const String appTagline = 'Your Islamic Companion';
  
  // Colors
  static const int primaryColorValue = 0xFF2E7D32;
  static const int secondaryColorValue = 0xFF1565C0;
  static const int accentColorValue = 0xFFFFB300;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Grid Layout
  static const int quickAccessColumns = 2;
  static const double cardBorderRadius = 16.0;
  static const double cardElevation = 4.0;
  
  // Islamic Greetings
  static const Map<String, Map<String, String>> islamicGreetings = {
    'morning': {
      'arabic': 'صباح الخير',
      'english': 'Good Morning',
      'transliteration': 'Sabah al-khayr'
    },
    'afternoon': {
      'arabic': 'مساء الخير',
      'english': 'Good Afternoon',
      'transliteration': 'Masa al-khayr'
    },
    'evening': {
      'arabic': 'مساء الخير',
      'english': 'Good Evening',
      'transliteration': 'Masa al-khayr'
    },
    'night': {
      'arabic': 'تصبح على خير',
      'english': 'Good Night',
      'transliteration': 'Tusbih ala khayr'
    }
  };
}

// lib/core/constants/api_constants.dart
class ApiConstants {
  // Aladhan API
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String prayerTimesEndpoint = '/calendar';
  static const String islamicDateEndpoint = '/gToH';
  static const String qiblaEndpoint = '/qibla';
  
  // Al-Quran Cloud API
  static const String quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String randomVerseEndpoint = '/ayah';
  static const String surahEndpoint = '/surah';
  
  // Hadith API
  static const String hadithBaseUrl = 'https://api.hadith.sutanlab.id';
  static const String randomHadithEndpoint = '/hadith/random';
  
  // Default Calculation Method
  static const String defaultCalculationMethod = '2'; // ISNA
  static const String defaultMadhab = '0'; // Shafi
}
