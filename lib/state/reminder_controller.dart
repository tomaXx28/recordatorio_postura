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

  // -----------------------------------------
  // LOAD DATA
  // -----------------------------------------
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

  // -----------------------------------------
  // FILTER LOGIC
  // -----------------------------------------
  void changeFilter(ReminderFilter filter) {
    currentFilter = filter;
    notifyListeners();
  }

  List<Reminder> get filteredReminders {
    switch (currentFilter) {
      case ReminderFilter.pending:
        return _reminders.where((r) => r.status == ReminderStatus.pending).toList();
      case ReminderFilter.completed:
        return _reminders.where((r) => r.status == ReminderStatus.completed).toList();
      case ReminderFilter.skipped:
        return _reminders.where((r) => r.status == ReminderStatus.skipped).toList();
      default:
        return _reminders;
    }
  }

  Future<void> delayAndSkip(Reminder reminder) async {
  // Mover 5 minutos adelante
  reminder.dateTime = DateTime.now().add(const Duration(minutes: 5));

  // IMPORTANTE: volverlo a pendiente
  reminder.status = ReminderStatus.pending;

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

  // -----------------------------------------
  // CRUD
  // -----------------------------------------
  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    notifyListeners();
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

  // -----------------------------------------
  // STATUS UPDATE
  // -----------------------------------------
  Future<void> markAsCompleted(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    reminder.status = ReminderStatus.completed;

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
