import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recordatorios_postura/main.dart' show navigatorKey;
import '../models/reminder.dart';
import '../state/reminder_controller.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

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
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Permiso para Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  
  //  ACCIONES DE NOTIFICACIÓN: COMPLETAR / APLAZAR / PERSONALIZADO
 
  static Future<void> _onNotificationTap(NotificationResponse details) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final controller = context.read<ReminderController>();

    final reminder = controller.reminders.firstWhereOrNull(
      (r) => r.hashCode == details.id,
    );

    if (reminder == null) return;

  
    //  BOTÓN: COMPLETAR
  
    if (details.actionId == 'complete_action') {
      reminder.status = ReminderStatus.completed;
      await controller.updateReminder(reminder);
      return;
    }

    
    // BOTÓN: APLAZAR 5 MIN
    
    if (details.actionId == 'snooze_action') {
      reminder.dateTime = DateTime.now().add(const Duration(minutes: 5));
      await controller.updateReminder(reminder);
      await NotificationService().scheduleReminder(reminder);
      return;
    }

    
    //  FRECUENCIA PERSONALIZADA: CADA X DÍAS
    
    if (reminder.frequency == ReminderFrequency.custom) {
      final interval = reminder.customIntervalDays ?? 1;

      reminder.dateTime = reminder.dateTime.add(Duration(days: interval));

      await controller.updateReminder(reminder);
      await NotificationService().scheduleReminder(reminder);
    }
  }


  //  Calcula la próxima fecha según intervalo personalizado

  DateTime getNextCustomDate(Reminder reminder) {
    final interval = reminder.customIntervalDays;

    if (interval == null || interval <= 0) {
      return reminder.dateTime;
    }

    final now = DateTime.now();
    DateTime next = reminder.dateTime;

    while (next.isBefore(now)) {
      next = next.add(Duration(days: interval));
    }

    return next;
  }

  //  PROGRAMA LA NOTIFICACIÓN SEGÚN LA FRECUENCIA
  
  Future<void> scheduleReminder(Reminder reminder) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Recordatorios de postura',
      channelDescription: 'Recordatorios creados en la app',
      importance: Importance.high,
      priority: Priority.high,


      actions: const [
        AndroidNotificationAction(
          'complete_action',
          'Completar',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_action',
          'Aplazar 5 min',
          showsUserInterface: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Frecuencias normales
    switch (reminder.frequency) {
      case ReminderFrequency.once:
        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(reminder.dateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case ReminderFrequency.daily:
        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(reminder.dateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case ReminderFrequency.weekly:
        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(reminder.dateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case ReminderFrequency.custom:
        final next = getNextCustomDate(reminder);

        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(next, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
    }
  }


  Future<void> cancelReminder(Reminder reminder) async {
    await _plugin.cancel(reminder.hashCode);
  }
}
