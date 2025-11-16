import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../state/reminder_controller.dart';

class ReminderEvaluator {
  // evita que se abran múltiples popups
  static bool isDialogOpen = false;

  static Future<void> evaluate(BuildContext context) async {
    final controller = context.read<ReminderController>();
    final reminders = controller.reminders;

    if (reminders.isEmpty) return;

    final now = DateTime.now();

    final vencidos = reminders.where((r) {
      return r.status == ReminderStatus.pending &&
          r.dateTime.isBefore(now);
    }).toList();

    if (vencidos.isEmpty) return;

    vencidos.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final reminder = vencidos.first;

    if (!isDialogOpen) {
      isDialogOpen = true;
      _showPopup(context, controller, reminder);
    }
  }

  static void _showPopup(
    BuildContext context,
    ReminderController controller,
    Reminder reminder,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text(
            "Recordatorio de postura",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "¿Realizaste este recordatorio?\n\n• ${reminder.title}",
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                ReminderEvaluator.isDialogOpen = false;
                
                controller.markAsCompleted(reminder.id);
              },
              child: const Text(
                "Completado",
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                ReminderEvaluator.isDialogOpen = false;

                controller.delayAndSkip(reminder);
              },
              child: const Text(
                "Omitir (5 min)",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}
