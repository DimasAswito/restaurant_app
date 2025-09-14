import 'package:flutter/material.dart';
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
    _initNotification();
    _loadSettings();
  }

  Future<void> _initNotification() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notifikasi diterima dengan payload: ${response.payload}');
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminder',
      description: 'Reminder harian jam 11 siang',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(themeKey) ?? false;
    _isReminderActive = prefs.getBool(reminderKey) ?? false;

    if (_isReminderActive) {
      await scheduleDailyReminderAt(11, 0);
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
        await scheduleDailyReminderAt(11, 0);
      } catch (e) {
        print("Gagal aktifkan reminder: $e");
      }
    } else {
      await _cancelReminder();
    }

    notifyListeners();
  }

  Future<void> scheduleDailyReminderAt(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Waktunya makan siang!',
      'Jangan lupa makan siang hari ini',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'Reminder harian',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("Notifikasi dijadwalkan pada: $scheduled");
  }

  Future<void> _cancelReminder() async {
    await flutterLocalNotificationsPlugin.cancel(1);
  }
}
