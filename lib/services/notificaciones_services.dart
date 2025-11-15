import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reminder.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = "recordatorios_postura_channel";

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
  initSettings,
  onDidReceiveNotificationResponse: (details) {
    print("🔔 NOTIFICACIÓN DISPARADA: ${details.payload}");
  },
);

    // Permiso para Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> testInstant() async {
  final android = AndroidNotificationDetails(
    channelId,
    'Test canal',
    channelDescription: 'Prueba inmediata',
    importance: Importance.high,
    priority: Priority.high,
  );

  await _plugin.show(
    999,
    'Test instantáneo',
    'Si ves esto, el sistema funciona',
    NotificationDetails(android: android),
  );
}

Future<void> testScheduleBasic() async {
  final now = DateTime.now().add(const Duration(minutes: 1));

  print("⏱ PROGRAMANDO TEST BASICO PARA: $now");

  final androidDetails = AndroidNotificationDetails(
    channelId,
    "Prueba básica",
    channelDescription: "Test sin TZ",
    importance: Importance.high,
    priority: Priority.high,
  );

  final notificationDetails = NotificationDetails(android: androidDetails);

  await _plugin.zonedSchedule(
    321, // id fijo para esta prueba
    "Notificación de test",
    "Si ves esto, la programación básica funciona",
    tz.TZDateTime.from(now, tz.local),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}



  Future<void> scheduleReminder(Reminder reminder) async {
    print("📌 AGENDANDO NOTI PARA: ${reminder.dateTime}");

    final androidDetails = AndroidNotificationDetails(
      channelId,
      "Recordatorios de postura",
      channelDescription: "Recordatorios programados por la app",
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.zonedSchedule(
      reminder.hashCode,
      reminder.title,
      reminder.description,
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(Reminder reminder) async {
    await _plugin.cancel(reminder.hashCode);
  }
}
