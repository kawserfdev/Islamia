import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamia/data/models/prayer/prayer_times_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'dart:typed_data';

class PrayerNotificationService {
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();
  factory PrayerNotificationService() => _instance;
  PrayerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
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

  Future<void> schedulePrayerNotifications(
    PrayerTimesModel prayerTimes,
    PrayerSettings settings,
  ) async {
    if (!settings.notificationsEnabled) return;

    // Cancel existing notifications
    await _notifications.cancelAll();

    final prayers = prayerTimes.getAllPrayerSchedules();

    for (final prayer in prayers) {
      if (settings.prayerNotifications[prayer.type.name] == true) {
        await _schedulePrayerNotification(
          prayer,
          settings,
          prayerTimes.location,
        );
      }
    }
  }

  Future<void> _schedulePrayerNotification(
    PrayerSchedule prayer,
    PrayerSettings settings,
    LocationModel location,
  ) async {
    final notificationTime = prayer.time.subtract(
      Duration(minutes: settings.reminderMinutes),
    );

    if (notificationTime.isBefore(DateTime.now())) return;

    final notificationId = prayer.type.name.hashCode + prayer.time.day;

    await _notifications.zonedSchedule(
      notificationId,
      _getPrayerNotificationTitle(prayer.type),
      _getPrayerNotificationBody(prayer.type, prayer.time, location),
      tz.TZDateTime.from(notificationTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times',
          'Prayer Times',
          channelDescription: 'Prayer time notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound:
              settings.adhanEnabled
                  ? RawResourceAndroidNotificationSound(
                    'adhan_${settings.adhanSound}',
                  )
                  : null,
          enableVibration: settings.vibrationEnabled,
          vibrationPattern: _getVibrationPattern(),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(
            _getPrayerNotificationBody(prayer.type, prayer.time, location),
            contentTitle: _getPrayerNotificationTitle(prayer.type),
          ),
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'prayer_notification',
          sound:
              settings.adhanEnabled ? 'adhan_${settings.adhanSound}.mp3' : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '${prayer.type.name}_${prayer.time.millisecondsSinceEpoch}',
    );
  }

  Future<void> playAdhan(String adhanType, double volume) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(AssetSource('audio/adhan_$adhanType.mp3'));
    } catch (e) {
      print('Error playing adhan: $e');
    }
  }

  Future<void> stopAdhan() async {
    await _audioPlayer.stop();
  }

  Future<void> triggerVibration() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(
        pattern: [0, 500, 200, 500, 200, 500],
        intensities: [0, 128, 0, 255, 0, 128],
      );
    }
  }

  Future<void> showImmediatePrayerNotification(
    PrayerType prayerType,
    DateTime prayerTime,
    LocationModel location,
    PrayerSettings settings,
  ) async {
    final notificationId =
        prayerType.name.hashCode + DateTime.now().millisecondsSinceEpoch;

    await _notifications.show(
      notificationId,
      _getPrayerNotificationTitle(prayerType),
      _getPrayerNotificationBody(prayerType, prayerTime, location),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate_prayer',
          'Immediate Prayer Notification',
          channelDescription: 'Immediate prayer notifications',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          sound:
              settings.adhanEnabled
                  ? RawResourceAndroidNotificationSound(
                    'adhan_${settings.adhanSound}',
                  )
                  : null,
          enableVibration: settings.vibrationEnabled,
          vibrationPattern: _getVibrationPattern(),
          fullScreenIntent: true,
          actions: [
            const AndroidNotificationAction(
              'mark_prayed',
              'Mark as Prayed',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_check'),
            ),
            const AndroidNotificationAction(
              'snooze',
              'Remind in 5 min',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_snooze'),
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'immediate_prayer',
          sound:
              settings.adhanEnabled ? 'adhan_${settings.adhanSound}.mp3' : null,
        ),
      ),
      payload:
          '${prayerType.name}_${prayerTime.millisecondsSinceEpoch}_immediate',
    );

    if (settings.adhanEnabled) {
      await playAdhan(settings.adhanSound, settings.adhanVolume);
    }

    if (settings.vibrationEnabled) {
      await triggerVibration();
    }
  }

  String _getPrayerNotificationTitle(PrayerType prayerType) {
    switch (prayerType) {
      case PrayerType.fajr:
        return 'Fajr Prayer Time';
      case PrayerType.dhuhr:
        return 'Dhuhr Prayer Time';
      case PrayerType.asr:
        return 'Asr Prayer Time';
      case PrayerType.maghrib:
        return 'Maghrib Prayer Time';
      case PrayerType.isha:
        return 'Isha Prayer Time';
      case PrayerType.tahajjud:
        return 'Tahajjud Time';
      case PrayerType.sunrise:
        return 'Sunrise';
    }
  }

  String _getPrayerNotificationBody(
    PrayerType prayerType,
    DateTime prayerTime,
    LocationModel location,
  ) {
    final timeString = _formatTime(prayerTime);
    return 'It\'s time for ${prayerType.displayName} prayer at $timeString in ${location.city}';
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12
            ? time.hour - 12
            : time.hour == 0
            ? 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Int64List _getVibrationPattern() {
    return Int64List.fromList([0, 500, 200, 500, 200, 800]);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split('_');
    if (parts.length >= 2) {
      final prayerType = parts[0];
      final timestamp = int.tryParse(parts[1]);

      if (response.actionId == 'mark_prayed') {
        // Handle mark as prayed action
        _handleMarkAsPrayed(prayerType, timestamp);
      } else if (response.actionId == 'snooze') {
        // Handle snooze action
        _handleSnooze(prayerType, timestamp);
      }
    }
  }

  void _handleMarkAsPrayed(String prayerType, int? timestamp) {
    // This would typically call a callback or use a stream to notify the app
    print('Marked $prayerType as prayed');
  }

  void _handleSnooze(String prayerType, int? timestamp) {
    // Schedule a new notification in 5 minutes
    print('Snoozed $prayerType for 5 minutes');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    await _audioPlayer.stop();
  }

  Future<void> cancelPrayerNotification(PrayerType prayerType) async {
    final notificationId = prayerType.name.hashCode;
    await _notifications.cancel(notificationId);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
