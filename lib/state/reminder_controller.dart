import 'package:flutter/foundation.dart';
import 'package:recordatorios_postura/services/firebase_services.dart';
import '../models/reminder.dart';
import '../services/local_storage_service.dart';


class ReminderController extends ChangeNotifier {
  final List<Reminder> _reminders = [];

  final LocalStorageService _local = LocalStorageService();
  final FirebaseService _firebase = FirebaseService();

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
    _firebase.listenReminders().listen((remoteList) {
      _reminders
        ..clear()
        ..addAll(remoteList);

      notifyListeners();
      _local.saveReminders(_reminders); // sincroniza local
    });
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    notifyListeners();

    await _local.saveReminders(_reminders);
    await _firebase.saveReminder(reminder);
  }

  Future<void> updateReminder(Reminder updated) async {
    final index = _reminders.indexWhere((r) => r.id == updated.id);

    if (index != -1) {
      _reminders[index] = updated;
      notifyListeners();

      await _local.saveReminders(_reminders);
      await _firebase.saveReminder(updated);
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();

    await _local.saveReminders(_reminders);
    await _firebase.deleteReminder(id);
  }
}
