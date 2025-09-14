import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';

class SettingProvider extends ChangeNotifier {
  static const String themeKey = "theme_dark";
  static const String reminderKey = "daily_reminder";

  bool _isDarkTheme = false;
  bool _isReminderActive = false;

  bool get isDarkTheme => _isDarkTheme;
  bool get isReminderActive => _isReminderActive;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SettingProvider() {
    _init();
  }

  Future<void> _init() async {
    await configureLocalTimeZone();
    await _initNotification();
    await _loadSettings();
  }

  Future<void> _initNotification() async {
    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notifikasi ditekan, payload: ${response.payload}');
      },
    );
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  tz.TZDateTime _nextInstanceOfElevenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(themeKey) ?? false;
    _isReminderActive = prefs.getBool(reminderKey) ?? false;

    if (_isReminderActive) {
      await scheduleDailyElevenAMNotification(id: 1);
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkTheme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, value);
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    _isReminderActive = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(reminderKey, value);

    if (value) {
      try {
        if (Platform.isAndroid) {
          final androidPlugin = flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

          final bool? granted = await androidPlugin
              ?.requestNotificationsPermission();
          if (granted != true) {
            print("Izin notifikasi ditolak");
            return;
          }
        }
        await scheduleDailyElevenAMNotification(id: 1);
      } catch (e) {
        print("Gagal aktifkan reminder: $e");
      }
    } else {
      await _cancelReminder();
    }

    notifyListeners();
  }

  Future<void> scheduleDailyElevenAMNotification({
    required int id,
    String channelId = "3",
    String channelName = "Schedule Notification",
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      icon: '@drawable/ic_notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final datetimeSchedule = _nextInstanceOfElevenAM();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Waktunya makan siang!',
      'Jangan lupa makan siang hari ini',
      datetimeSchedule,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  Future<void> _cancelReminder() async {
    await flutterLocalNotificationsPlugin.cancel(1);
  }
}
