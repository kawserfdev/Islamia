import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar/islamic_event.dart';
import '../models/calendar/hijri_date.dart';
import '../models/calendar/daily_reminder.dart';
import '../database/calendar_database.dart';
import 'hijri_service.dart';

class IslamicEventsService {
  final CalendarDatabase _database = CalendarDatabase();
  final HijriService _hijriService = HijriService();
  final http.Client _httpClient;

  static const String _baseUrl = 'https://api.islamicfinder.us/v1';
  static const String _apiKey = 'YOUR_API_KEY';

  IslamicEventsService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // Get events for a specific date
  Future<List<IslamicEvent>> getEventsForDate(DateTime date) async {
    try {
      // Try to get events from online API first
      final onlineEvents = await _fetchOnlineEvents(date);
      
      // Get local events
      final localEvents = await _database.getEventsByDate(date);
      
      // Combine and return
      final allEvents = [...localEvents, ...onlineEvents];
      
      // Remove duplicates
      final uniqueEvents = <String, IslamicEvent>{};
      for (final event in allEvents) {
        uniqueEvents[event.id] = event;
      }
      
      return uniqueEvents.values.toList()
        ..sort((a, b) => a.title.compareTo(b.title));
        
    } catch (e) {
      // Fallback to local events only
      return await _database.getEventsByDate(date);
    }
  }

  // Get events for a month
  Future<List<IslamicEvent>> getEventsForMonth(int year, int month) async {
    try {
      final localEvents = await _database.getEventsByMonth(year, month);
      
      // Calculate Hijri events for this month
      final hijriEvents = await _calculateRecurringHijriEvents(year, month);
      
      return [...localEvents, ...hijriEvents];
    } catch (e) {
      return await _database.getEventsByMonth(year, month);
    }
  }

  // Fetch events from online API
  Future<List<IslamicEvent>> _fetchOnlineEvents(DateTime date) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/islamic-events'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = <IslamicEvent>[];
        
        for (final eventData in data['events']) {
          final event = _parseOnlineEvent(eventData, date);
          if (event != null) {
            events.add(event);
            // Cache the event locally
            await _database.insertEvent(event);
          }
        }
        
        return events;
      }
    } catch (e) {
      print('Error fetching online events: $e');
    }
    
    return [];
  }

  // Parse online event data
  IslamicEvent? _parseOnlineEvent(Map<String, dynamic> data, DateTime date) {
    try {
      return IslamicEvent(
        id: data['id'] ?? _generateEventId(),
        title: data['title'] ?? '',
        titleArabic: data['title_arabic'] ?? '',
        description: data['description'] ?? '',
        descriptionArabic: data['description_arabic'] ?? '',
        gregorianDate: date,
        hijriDate: HijriDate.fromJson(data['hijri_date'] ?? {}),
        type: IslamicEventType.values.firstWhere(
          (e) => e.name == data['type'],
          orElse: () => IslamicEventType.religious,
        ),
        category: IslamicEventCategory.values.firstWhere(
          (e) => e.name == data['category'],
          orElse: () => IslamicEventCategory.general,
        ),
        significances: List<String>.from(data['significances'] ?? []),
        practices: List<String>.from(data['practices'] ?? []),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing event: $e');
      return null;
    }
  }

  // Calculate recurring Hijri events
  Future<List<IslamicEvent>> _calculateRecurringHijriEvents(int year, int month) async {
    final events = <IslamicEvent>[];
    final recurringEvents = await _database.getEventsByCategory(IslamicEventCategory.general);
    
    for (final event in recurringEvents.where((e) => e.isRecurring && e.recurrenceType == RecurrenceType.hijri_yearly)) {
      // Calculate this year's occurrence
      final hijriDate = await _hijriService.gregorianToHijri(DateTime(year, month, 1));
      final eventGregorianDate = _hijriService.hijriToGregorian(
        event.hijriDate.day,
        event.hijriDate.month,
        hijriDate.year,
      );
      
      if (eventGregorianDate.year == year && eventGregorianDate.month == month) {
        events.add(event.copyWith(
          gregorianDate: eventGregorianDate,
          hijriDate: event.hijriDate.copyWith(year: hijriDate.year),
        ));
      }
    }
    
    return events;
  }

  // Get daily reminder
  Future<DailyReminder> getDailyReminder(DateTime date) async {
    var reminder = await _database.getDailyReminder(date);
    
    if (reminder == null) {
      // Generate new daily reminder
      reminder = await _generateDailyReminder(date);
      await _database.insertDailyReminder(reminder);
    }
    
    return reminder;
  }

  // Generate daily reminder
  Future<DailyReminder> _generateDailyReminder(DateTime date) async {
    final hijriDate = await _hijriService.gregorianToHijri(date);
    
    // Get Quran verse for the day
    final verseData = await _getVerseOfTheDay(date);
    
    // Get Hadith for the day
    final hadithData = await _getHadithOfTheDay(date);
    
    // Get Islamic quote
    final quoteData = await _getQuoteOfTheDay(date);
    
    // Get moon phase info
    final moonPhaseInfo = await _getMoonPhaseInfo(date);
    
    return DailyReminder(
      id: _generateReminderId(date),
      date: date,
      hijriDate: hijriDate,
      quranVerse: verseData['verse'] ?? '',
      quranVerseArabic: verseData['verse_arabic'] ?? '',
      translation: verseData['translation'] ?? '',
      hadith: hadithData['hadith'] ?? '',
      hadithArabic: hadithData['hadith_arabic'] ?? '',
      hadithSource: hadithData['source'] ?? '',
      islamicQuote: quoteData['quote'] ?? '',
      islamicQuoteArabic: quoteData['quote_arabic'] ?? '',
      author: quoteData['author'] ?? '',
      dailyPractices: _getDailyPractices(hijriDate),
      supplications: _getDailySupplications(hijriDate),
      moonPhaseInfo: moonPhaseInfo,
      createdAt: DateTime.now(),
    );
  }

  // Get verse of the day (simplified - you can integrate with Quran API)
  Future<Map<String, String>> _getVerseOfTheDay(DateTime date) async {
    // Simple algorithm to get different verse each day
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final surahNumber = (dayOfYear % 114) + 1;
    final ayahNumber = (date.day % 10) + 1;
    
    // This should be replaced with actual Quran API call
    return {
      'verse': 'And whoever relies upon Allah - then He is sufficient for him.',
      'verse_arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'translation': 'Indeed Allah will accomplish His purpose.',
      'reference': 'Quran $surahNumber:$ayahNumber'
    };
  }

  // Get Hadith of the day
  Future<Map<String, String>> _getHadithOfTheDay(DateTime date) async {
    final hadithIndex = date.day % 10;
    
    final hadiths = [
      {
        'hadith': 'The world is green and beautiful, and Allah has appointed you as His stewards over it.',
        'hadith_arabic': 'إن الدنيا خضرة حلوة، وإن الله مستخلفكم فيها',
        'source': 'Sahih Muslim'
      },
      // Add more hadiths...
    ];
    
    return hadiths[hadithIndex % hadiths.length];
  }

  // Get quote of the day
  Future<Map<String, String>> _getQuoteOfTheDay(DateTime date) async {
    final quoteIndex = date.day % 10;
    
    final quotes = [
      {
        'quote': 'Patience is a pillar of faith.',
        'quote_arabic': 'الصبر من الإيمان',
        'author': 'Prophet Muhammad (PBUH)'
      },
      // Add more quotes...
    ];
    
    return quotes[quoteIndex % quotes.length];
  }

  // Get daily practices based on Islamic month
  List<String> _getDailyPractices(HijriDate hijriDate) {
    switch (hijriDate.month) {
      case 1: // Muharram
        return ['Reflect on the Hijra', 'Seek forgiveness', 'Fast on the 10th (Ashura)'];
      case 7: // Rajab
        return ['Increase in worship', 'Night prayers', 'Seek forgiveness'];
      case 8: // Sha\'ban
        return ['Prepare for Ramadan', 'Increase fasting', 'Recite Quran'];
      case 9: // Ramadan
        return ['Fast from dawn to sunset', 'Tarawih prayers', 'Read Quran', 'Give charity'];
      case 12: // Dhu al-Hijjah
        return ['Fast first 9 days', 'Perform Hajj if able', 'Increase in dhikr'];
      default:
        return ['Five daily prayers', 'Read Quran', 'Dhikr and dua', 'Help others'];
    }
  }

  // Get daily supplications
  List<String> _getDailySupplications(HijriDate hijriDate) {
    return [
      'Morning and evening dhikr',
      'Istighfar (seeking forgiveness)',
      'Salawat on Prophet Muhammad',
      'Dua for guidance and protection',
    ];
  }

  // Get moon phase information
  Future<String> _getMoonPhaseInfo(DateTime date) async {
    // Simplified moon phase calculation
    final daysSinceNewMoon = (date.difference(DateTime(2000, 1, 6)).inDays) % 29.5;
    
    if (daysSinceNewMoon < 1) {
      return 'New Moon - Beginning of lunar month';
    } else if (daysSinceNewMoon < 7) {
      return 'Waxing Crescent - Growing moon';
    } else if (daysSinceNewMoon < 15) {
      return 'Full Moon - Complete illumination';
    } else {
      return 'Waning Moon - Decreasing illumination';
    }
  }

  // Create user event
  Future<String> createUserEvent({
    required String userId,
    required String title,
    required String description,
    required DateTime date,
    String eventType = 'personal',
    String color = '#2196F3',
    bool hasNotification = false,
    DateTime? notificationTime,
    bool isRecurring = false,
    RecurrenceType? recurrenceType,
  }) async {
    final eventId = _generateEventId();
    
    final event = {
      'id': eventId,
      'user_id': userId,
      'title': title,
      'description': description,
      'gregorian_date': date.toIso8601String(),
      'hijri_date': jsonEncode((await _hijriService.gregorianToHijri(date)).toJson()),
      'event_type': eventType,
      'color': color,
      'has_notification': hasNotification ? 1 : 0,
      'notification_time': notificationTime?.toIso8601String(),
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_type': recurrenceType?.name,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    await _database.insertUserEvent(event);
    return eventId;
  }

  // Update user event
  Future<void> updateUserEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? date,
    String? eventType,
    String? color,
    bool? hasNotification,
    DateTime? notificationTime,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (date != null) {
      updates['gregorian_date'] = date.toIso8601String();
      updates['hijri_date'] = jsonEncode((await _hijriService.gregorianToHijri(date)).toJson());
    }
    if (eventType != null) updates['event_type'] = eventType;
    if (color != null) updates['color'] = color;
    if (hasNotification != null) updates['has_notification'] = hasNotification ? 1 : 0;
    if (notificationTime != null) updates['notification_time'] = notificationTime.toIso8601String();
    if (isRecurring != null) updates['is_recurring'] = isRecurring ? 1 : 0;
    if (recurrenceType != null) updates['recurrence_type'] = recurrenceType.name;
    
    await _database.updateUserEvent(eventId, updates);
  }

  // Delete user event
  Future<void> deleteUserEvent(String eventId) async {
    await _database.deleteUserEvent(eventId);
  }

  // Get user events for date
  Future<List<Map<String, dynamic>>> getUserEventsForDate(String userId, DateTime date) async {
    return await _database.getUserEventsByDate(userId, date);
  }

  // Get all user events
  Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    return await _database.getUserEvents(userId);
  }

  // Search events
  Future<List<IslamicEvent>> searchEvents(String query) async {
    return await _database.searchEvents(query);
  }

  // Get events by category
  Future<List<IslamicEvent>> getEventsByCategory(IslamicEventCategory category) async {
    return await _database.getEventsByCategory(category);
  }

  // Get Islamic month information
  Future<Map<String, dynamic>?> getIslamicMonthInfo(int monthNumber) async {
    return await _database.getIslamicMonthInfo(monthNumber);
  }

  // Helper methods
  String _generateEventId() {
    return 'event_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  String _generateReminderId(DateTime date) {
    return 'reminder_${date.toIso8601String().split('T')[0]}';
  }

  // Dispose resources
  void dispose() {
    _httpClient.close();
  }
}