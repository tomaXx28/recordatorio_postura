enum ReminderStatus { pending, completed, skipped }

enum ReminderFrequency {
  once,      // Una vez
  daily,     // Diario
  weekly,    // Semanal
  custom,    // Cada n°dias
}

String frequencyToString(ReminderFrequency frequency) {
  switch (frequency) {
    case ReminderFrequency.daily:
      return 'daily';
    case ReminderFrequency.weekly:
      return 'weekly';
    case ReminderFrequency.custom:
      return 'custom';
    case ReminderFrequency.once:
    default:
      return 'once';
  }
}

ReminderFrequency stringToFrequency(String? value) {
  switch (value) {
    case 'daily':
      return ReminderFrequency.daily;
    case 'weekly':
      return ReminderFrequency.weekly;
    case 'custom':
      return ReminderFrequency.custom;
    case 'once':
    default:
      return ReminderFrequency.once;
  }
}

String statusToString(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.completed:
      return "completed";
    case ReminderStatus.skipped:
      return "skipped";
    default:
      return "pending";
  }
}

ReminderStatus stringToStatus(String value) {
  switch (value) {
    case "completed":
      return ReminderStatus.completed;
    case "skipped":
      return ReminderStatus.skipped;
    default:
      return ReminderStatus.pending;
  }
}

class Reminder {
  final String id;
  final String title;
  final String description;
  DateTime dateTime;
  ReminderStatus status;
  ReminderFrequency frequency;
  int? customIntervalDays;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.status = ReminderStatus.pending,
    this.frequency = ReminderFrequency.once,
    this.customIntervalDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'status': statusToString(status),
      'frequency': frequencyToString(frequency),
      'customIntervalDays': customIntervalDays,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    String statusString;

    if (rawStatus is int) {
      switch (rawStatus) {
        case 1:
          statusString = 'completed';
          break;
        case 2:
          statusString = 'skipped';
          break;
        default:
          statusString = 'pending';
      }
    } else if (rawStatus is String) {
      statusString = rawStatus;
    } else {
      statusString = 'pending';
    }

    // frecuencia (puede venir nula si es un registro antiguo)
    final freqString = json['frequency'] as String?;

    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      status: stringToStatus(statusString),
      frequency: stringToFrequency(freqString),
      customIntervalDays: json['customIntervalDays'],
    );
  }
}
