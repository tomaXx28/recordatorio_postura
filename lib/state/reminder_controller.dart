import 'package:flutter/foundation.dart';
import 'package:recordatorios_postura/services/firebase_services.dart';
import 'package:recordatorios_postura/services/notificaciones_services.dart';
import '../models/reminder.dart';
import '../services/local_storage_service.dart';

enum ReminderFilter { all, pending, completed, skipped }

class ReminderController extends ChangeNotifier {
  final List<Reminder> _reminders = [];

  final LocalStorageService _local = LocalStorageService();
  final FirebaseService _firebase = FirebaseService();

  ReminderFilter currentFilter = ReminderFilter.all;

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  ReminderController() {
    _loadInitialData();
    _listenFirebase();
  }

  Future<void> _loadInitialData() async {
    final saved = await _local.loadReminders();
    _reminders.addAll(saved);
    notifyListeners();
  }

  void _listenFirebase() {
    _firebase.listenReminders().listen((firebaseList) {
      _reminders
        ..clear()
        ..addAll(firebaseList);
      notifyListeners();
      _local.saveReminders(_reminders);
    });
  }

  void changeFilter(ReminderFilter filter) {
    currentFilter = filter;
    notifyListeners();
  }

  List<Reminder> get filteredReminders {
    switch (currentFilter) {
      case ReminderFilter.pending:
        return _reminders
            .where((r) => r.status == ReminderStatus.pending)
            .toList();
      case ReminderFilter.completed:
        return _reminders
            .where((r) => r.status == ReminderStatus.completed)
            .toList();
      case ReminderFilter.skipped:
        return _reminders
            .where((r) => r.status == ReminderStatus.skipped)
            .toList();
      default:
        return _reminders;
    }
  }

  // Aplazar 5 minutos y dejar como OMITIDO
  Future<void> delayAndSkip(Reminder reminder) async {
    reminder.dateTime = DateTime.now().add(const Duration(minutes: 5));
    reminder.status = ReminderStatus.skipped;

    notifyListeners();
    await _local.saveReminders(_reminders);
    await _firebase.saveReminder(reminder);
  }

  Future<void> updateStatus(String id, ReminderStatus status) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    reminder.status = status;

    notifyListeners();
    await _local.saveReminders(_reminders);
    await _firebase.saveReminder(reminder);
  }

  // CRUD
  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    notifyListeners();

    // Se mantiene la lógica de notificaciones como evidencia
    await NotificationService().schedule(reminder);

    await _local.saveReminders(_reminders);
    await _firebase.saveReminder(reminder);
  }

  Future<void> updateReminder(Reminder updated) async {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index == -1) return;

    _reminders[index] = updated;
    notifyListeners();

    await NotificationService().schedule(updated);
    await _local.saveReminders(_reminders);
    await _firebase.saveReminder(updated);
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();

    await _local.saveReminders(_reminders);
    await _firebase.deleteReminder(id);
  }

  //  Lógica de completar según FRECUENCIA
  Future<void> markAsCompleted(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);

    switch (reminder.frequency) {
      case ReminderFrequency.once:
        reminder.status = ReminderStatus.completed;
        break;

      case ReminderFrequency.daily:
        reminder.dateTime = reminder.dateTime.add(const Duration(days: 1));
        reminder.status = ReminderStatus.pending;
        break;

      case ReminderFrequency.weekly:
        reminder.dateTime = reminder.dateTime.add(const Duration(days: 7));
        reminder.status = ReminderStatus.pending;
        break;

      case ReminderFrequency.custom:
        final days = reminder.customIntervalDays ?? 1;
        reminder.dateTime = reminder.dateTime.add(Duration(days: days));
        reminder.status = ReminderStatus.pending;
        break;
    }

    notifyListeners();
    await _local.saveReminders(_reminders);
    await _firebase.saveReminder(reminder);
  }

  Future<void> markAsSkipped(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    reminder.status = ReminderStatus.skipped;

    notifyListeners();
    await _local.saveReminders(_reminders);
    await _firebase.saveReminder(reminder);
  }
}
