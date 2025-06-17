class ApiConstants {
  // Al-Quran Cloud API
  static const String quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String quranEditions = '$quranBaseUrl/edition';
  static const String quranSurahs = '$quranBaseUrl/surah';

  // Aladhan API for Prayer Times
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String prayerTimings = '$aladhanBaseUrl/timings';
  static const String qiblaDirection = '$aladhanBaseUrl/qibla';

  // Sunnah.com API (use alternative hadith API)
  static const String hadithBaseUrl = 'https://api.hadith.gading.dev';
  static const String hadithBooks = '$hadithBaseUrl/books';

  // Google Maps API
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Remember to replace with actual key later
  static const String placesApiUrl = 'https://maps.googleapis.com/maps/api/place';
}
