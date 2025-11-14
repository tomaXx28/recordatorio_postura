import 'package:flutter/foundation.dart';

enum ReminderStatus {
  pending,
  completed,
  skipped,
  postponed,
}

class Reminder {
  final String id;
  String title;
  String description;
  DateTime dateTime;
  ReminderStatus status;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.status = ReminderStatus.pending,
  });

  // Conversión a JSON para guardar más adelante en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'status': status.index,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      status: ReminderStatus.values[json['status']],
    );
  }
}
