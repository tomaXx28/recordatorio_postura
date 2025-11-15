import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recordatorios_postura/models/reminder.dart';

import 'package:recordatorios_postura/screens/edit_reminder_screen.dart';
import 'package:recordatorios_postura/state/reminder_controller.dart';
import 'package:recordatorios_postura/utils/filter_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios de postura'),
        centerTitle: true,
      ),
      body: Consumer<ReminderController>(
        builder: (context, controller, _) {
          // OJO: usamos la lista filtrada
          final reminders = controller.filteredReminders;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --------------------
                // FILTROS
                // --------------------
               Wrap(
  spacing: 8,
  runSpacing: 8,
  alignment: WrapAlignment.center,
  children: const [
    FilterButton(text: "Todos", filter: ReminderFilter.all),
    FilterButton(text: "Pendientes", filter: ReminderFilter.pending),
    FilterButton(text: "Completados", filter: ReminderFilter.completed),
    FilterButton(text: "Omitidos", filter: ReminderFilter.skipped),
  ],
),

                const SizedBox(height: 16),

                // --------------------
                // LISTA FILTRADA
                // --------------------
                Expanded(
                  child: reminders.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          itemCount: reminders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final reminder = reminders[index];
                            return _ReminderTile(reminder: reminder);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditReminderScreen(),
            ),
          );
        },
        label: const Text('Nuevo recordatorio'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// ----------------------------------------------------------
// ITEM DE LA LISTA
// ----------------------------------------------------------
class _ReminderTile extends StatelessWidget {
  final Reminder reminder;

  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Abrir pantalla de edición
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditReminderScreen(existing: reminder),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reminder.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${reminder.dateTime}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Menú (eliminar)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDelete(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este recordatorio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context
                  .read<ReminderController>()
                  .deleteReminder(reminder.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// ESTADO VACÍO
// ----------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.accessibility_new, size: 72),
            SizedBox(height: 16),
            Text(
              'Aún no tienes recordatorios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Crea tu primer recordatorio para ayudarte a mantener una mejor postura durante el día.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
