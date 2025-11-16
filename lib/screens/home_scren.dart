import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recordatorios_postura/auth/auth_service.dart';
import 'package:recordatorios_postura/auth/login_sreen.dart';
import 'package:recordatorios_postura/models/reminder.dart';
import 'dart:async';
import 'package:recordatorios_postura/screens/edit_reminder_screen.dart';
import 'package:recordatorios_postura/state/reminder_controller.dart';
import 'package:recordatorios_postura/utils/filter_button.dart';
import '../services/reminder_evaluator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? evaluatorTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // evaluar al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReminderEvaluator.evaluate(context);
    });

    // ⏱ iniciar timer cada 30 segundos
    evaluatorTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ReminderEvaluator.evaluate(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    evaluatorTimer?.cancel(); // ⛔ importante
    super.dispose();
  }

  // 👇 AQUI SE ACTIVA EL POPUP AL VOLVER A LA APP
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ReminderEvaluator.evaluate(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      appBar: AppBar(
        title: const Text(
          'Recordatorios de postura',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.black87),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Nuevo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditReminderScreen()),
          );
        },
      ),

      body: Consumer<ReminderController>(
        builder: (context, controller, _) {
          final reminders = controller.filteredReminders;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: const [
                    FilterButton(text: "Todos", filter: ReminderFilter.all),
                    FilterButton(
                      text: "Pendientes",
                      filter: ReminderFilter.pending,
                    ),
                    FilterButton(
                      text: "Completados",
                      filter: ReminderFilter.completed,
                    ),
                    FilterButton(
                      text: "Omitidos",
                      filter: ReminderFilter.skipped,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: reminders.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          itemCount: reminders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (_, index) {
                            final r = reminders[index];
                            return _ReminderCard(reminder: r);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// CARD DEL RECORDATORIO
class _ReminderCard extends StatelessWidget {
  final Reminder reminder;

  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(reminder.status);
    final statusText = _getStatusText(reminder.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// FILA SUPERIOR (hora + badge + menú)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatHora(reminder.dateTime),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const Spacer(),

              /// BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// MENÚ EDITAR / ELIMINAR
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditReminderScreen(existing: reminder),
                      ),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(context, reminder);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text("Editar"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Eliminar"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// TÍTULO
          Text(
            reminder.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            _formatFecha(reminder.dateTime),
            style: const TextStyle(fontSize: 17, color: Colors.black54),
          ),

          if (reminder.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reminder.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  static String _formatFecha(DateTime dt) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final dia = dt.day;
    final mes = meses[dt.month - 1];
    return "$dia de $mes";
  }

  static Color _getStatusColor(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.completed:
        return Colors.green.shade600;
      case ReminderStatus.skipped:
        return Colors.blue.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  static String _getStatusText(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.completed:
        return "Completado";
      case ReminderStatus.skipped:
        return "Omitido";
      default:
        return "Pendiente";
    }
  }
}

void _confirmDelete(BuildContext context, Reminder reminder) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar recordatorio'),
      content: const Text('¿Estás seguro de eliminar este recordatorio?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            context.read<ReminderController>().deleteReminder(reminder.id);
            Navigator.pop(context);
          },
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

/// ESTADO VACÍO
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.accessibility_new, size: 80, color: Colors.black54),
          SizedBox(height: 16),
          Text(
            'Aún no tienes recordatorios',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Crea un recordatorio para mejorar tu postura.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
