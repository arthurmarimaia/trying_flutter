import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _enabled = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    try {
      await _plugin.initialize(settings);
      _enabled = true;
    } catch (_) {
      _enabled = false;
    }
  }

  static Future<void> showNotification(String title, String body) async {
    if (!_enabled) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'tamagotchi_channel',
        'Lembretes do Tamagotchi',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      await _plugin.show(0, title, body, notificationDetails);
    } catch (_) {
      // Ignorar falhas em ambiente de teste ou plataformas sem suporte.
    }
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    if (!_enabled) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'tamagotchi_channel',
        'Lembretes do Tamagotchi',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      tz.initializeTimeZones();
      final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  static Future<void> cancelNotification(int id) async {
    if (!_enabled) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  static Future<void> cancelAllNotifications() async {
    if (!_enabled) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
