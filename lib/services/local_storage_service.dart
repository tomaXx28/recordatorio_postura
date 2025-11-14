import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

class LocalStorageService {
  static const String _key = 'reminders';

  Future<List<Reminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Reminder.fromJson(e)).toList();
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = reminders.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(_key, jsonString);
  }
}
