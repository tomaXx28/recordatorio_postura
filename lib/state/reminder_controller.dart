import 'package:flutter/foundation.dart';
import '../models/reminder.dart';

class ReminderController extends ChangeNotifier {
  final List<Reminder> _reminders = [];

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void updateReminder(Reminder updated) {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _reminders[index] = updated;
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
