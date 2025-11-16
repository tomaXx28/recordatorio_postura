import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recordatorios_postura/main.dart' show navigatorKey;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../models/reminder.dart';
import '../state/reminder_controller.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = "recordatorios_postura_channel";

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // TAP EN NOTIFICACIÓN / ACCIONES
  static Future<void> _onTap(NotificationResponse details) async {
    
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final controller = context.read<ReminderController>();

    final reminder = controller.reminders.firstWhereOrNull(
      (r) => r.hashCode == details.id,
    );
    if (reminder == null) return;

    // COMPLETAR
    if (details.actionId == 'complete_action') {
      reminder.status = ReminderStatus.completed;
      await controller.updateReminder(reminder);
      return;
    }

    // APLAZAR 5 MIN
    if (details.actionId == 'snooze_action') {
      reminder.dateTime = DateTime.now().add(const Duration(minutes: 5));
      await controller.updateReminder(reminder);
      await NotificationService().schedule(reminder);
      return;
    }

    // FRECUENCIA PERSONALIZADA
    if (reminder.frequency == ReminderFrequency.custom) {
      final interval = reminder.customIntervalDays ?? 1;
      reminder.dateTime = reminder.dateTime.add(Duration(days: interval));

      await controller.updateReminder(reminder);
      await NotificationService().schedule(reminder);
    }
  }

  // CALCULAR PRÓXIMA FECHA PERSONALIZADA
  DateTime getNextCustom(Reminder r) {
    final interval = r.customIntervalDays ?? 1;
    DateTime next = r.dateTime;

    while (next.isBefore(DateTime.now())) {
      next = next.add(Duration(days: interval));
    }

    return next;
  }

  
  // PROGRAMAR NOTIFICACIÓN
  Future<void> schedule(Reminder reminder) async {

  
  if (reminder.dateTime.isBefore(DateTime.now())) {
    print(" Recordatorio con fecha pasada: no se programa notificación");
    return;
  }
    print("programando noti");
    print("Ahora: ${DateTime.now()}");
    print("Recordatorio: ${reminder.dateTime}");
    print(" Ahora: ${tz.TZDateTime.now(tz.local)}");
    print(" Programada: ${tz.TZDateTime.from(reminder.dateTime, tz.local)}");
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

    final details = NotificationDetails(android: androidDetails);

    final scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

    switch (reminder.frequency) {
      case ReminderFrequency.once:
        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(reminder.dateTime, tz.local),
          details,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case ReminderFrequency.daily:
        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(reminder.dateTime, tz.local),
          details,
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case ReminderFrequency.weekly:
        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(reminder.dateTime, tz.local),
          details,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case ReminderFrequency.custom:
        final next = getNextCustom(reminder);

        return _plugin.zonedSchedule(
          reminder.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(next, tz.local),
          details,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
    }
  }


  Future<void> cancel(Reminder reminder) async {
    await _plugin.cancel(reminder.hashCode);
  }
}
