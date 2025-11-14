import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../services/local_storage_service.dart';

class ReminderController extends ChangeNotifier {
  final List<Reminder> _reminders = [];
  final LocalStorageService _storage = LocalStorageService();

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  ReminderController() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final savedList = await _storage.loadReminders();
    _reminders.addAll(savedList);
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    await _storage.saveReminders(_reminders);
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateReminder(Reminder updated) async {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _reminders[index] = updated;
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveToStorage();
  }
}
