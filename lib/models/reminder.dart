enum ReminderStatus { pending, completed, skipped }

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
  final DateTime dateTime;
  ReminderStatus status;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.status = ReminderStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "dateTime": dateTime.toIso8601String(),
      "status": statusToString(status),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
  final rawStatus = json["status"];

  // Convertir números viejos (0,1,2) a strings
  String statusString;
  if (rawStatus is int) {
    switch (rawStatus) {
      case 1:
        statusString = "completed";
        break;
      case 2:
        statusString = "skipped";
        break;
      default:
        statusString = "pending";
    }
  } else if (rawStatus is String) {
    statusString = rawStatus;
  } else {
    statusString = "pending";
  }

  return Reminder(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    dateTime: DateTime.parse(json["dateTime"]),
    status: stringToStatus(statusString),
  );
}
}
