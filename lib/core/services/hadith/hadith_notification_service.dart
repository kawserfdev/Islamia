import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamia/data/models/hadith/hadith_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

class HadithNotificationService {
  static final HadithNotificationService _instance =
      HadithNotificationService._internal();
  factory HadithNotificationService() => _instance;
  HadithNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final iosPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    bool granted = true;

    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? false;
    }

    if (iosPlugin != null) {
      granted =
          await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return granted;
  }

  Future<void> scheduleDailyHadithNotification(TimeOfDay time) async {
    // Initialize time zone data (important for zonedSchedule)
    tzData.initializeTimeZones();

    await _notifications.zonedSchedule(
      0, // notification ID
      '📜 Daily Hadith',
      'Your daily hadith is ready to read 📖',
      _nextInstanceOfTime(time), // scheduled time
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_hadith',
          'Daily Hadith',
          channelDescription: 'Get a reminder every day to read a Hadith',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(categoryIdentifier: 'daily_hadith'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Future<void> scheduleDailyHadith({
  //   required TimeOfDay time,
  //   bool enabled = true,
  // }) async {
  //   await _notifications.cancelAll();

  //   if (!enabled) return;

  //   // Schedule daily notification
  //   await _notifications.zonedSchedule(
  //     0, // notification ID
  //     'Daily Hadith',
  //     'Your daily hadith is ready to read',
  //     _nextInstanceOfTime(time),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'daily_hadith',
  //         'Daily Hadith',
  //         channelDescription: 'Daily hadith notifications',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         icon: '@mipmap/ic_launcher',
  //       ),
  //       iOS: DarwinNotificationDetails(
  //         categoryIdentifier: 'daily_hadith',
  //       ),
  //     ),
  //     matchDateTimeComponents: DateTimeComponents.time, //androidScheduleMode: time.hour,
  //    // androidScheduleMode: enabled.address,
  //     //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }

  Future<void> showHadithNotification(HadithModel hadith) async {
    final translation = hadith.getTranslation('en');

    await _notifications.show(
      hadith.id.hashCode,
      'New Hadith - ${hadith.collection}',
      translation.isNotEmpty
          ? translation.substring(
                0,
                translation.length > 100 ? 100 : translation.length,
              ) +
              '...'
          : hadith.arabicText.substring(
                0,
                hadith.arabicText.length > 100 ? 100 : hadith.arabicText.length,
              ) +
              '...',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hadith_updates',
          'Hadith Updates',
          channelDescription: 'New hadith notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            translation.isNotEmpty ? translation : hadith.arabicText,
            contentTitle:
                '${hadith.collection} - Hadith ${hadith.hadithNumber}',
            summaryText: 'Grade: ${hadith.grade.displayName}',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'hadith_update',
        ),
      ),
      payload: hadith.id,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific hadith or screen based on payload
    print('Notification tapped: ${response.payload}');
  }
}
