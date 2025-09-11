import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
        print('Notifikasi ditekan: ${response.payload}');
      },
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminder',
      description: 'Reminder harian jam 11 siang',
      importance: Importance.max,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(themeKey) ?? false;
    _isReminderActive = prefs.getBool(reminderKey) ?? false;

    if (_isReminderActive) {
      await _scheduleDailyReminder();
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
      await _requestNotificationPermission();

      try {
        if (Platform.isAndroid) {
          final plugin = FlutterLocalNotificationsPlugin();

          final bool? granted = await plugin
              .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
              ?.requestExactAlarmsPermission();

          if (granted == false) {
            const platform = MethodChannel('flutter_local_notifications');
            await platform.invokeMethod('openSystemSettings');
            return;
          }
        }
        await _scheduleDailyReminder();
      } catch (e) {
        print("Gagal aktifkan reminder: $e");
      }
    } else {
      await _cancelReminder();
    }

    notifyListeners();
  }

  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final granted = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        if (granted == false) {
          print("Permission notifikasi ditolak");
        }
      }
    }
  }

  Future<void> _scheduleDailyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      17,
      55,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Waktunya makan siang!',
      'Jangan lupa makan siang hari ini 🍲',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'Reminder harian jam 11 siang',
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