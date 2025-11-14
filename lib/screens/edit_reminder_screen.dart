import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../state/reminder_controller.dart';
import 'package:uuid/uuid.dart';


class EditReminderScreen extends StatefulWidget {
  final Reminder? existing;

  const EditReminderScreen({super.key, this.existing});

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final r = widget.existing!;
      _titleCtrl = TextEditingController(text: r.title);
      _descCtrl = TextEditingController(text: r.description);

      _selectedDate = r.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(r.dateTime);
    } else {
      _titleCtrl = TextEditingController();
      _descCtrl = TextEditingController();

      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 2),
      initialDate: _selectedDate,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final controller = context.read<ReminderController>();

    if (isEditing) {
      final orig = widget.existing!;
      final updated = Reminder(
        id: orig.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dateTime: combinedDateTime,
        status: orig.status,
      );
      controller.updateReminder(updated);
    } else {
      final newR = Reminder(
        id: _uuid.v4(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dateTime: combinedDateTime,
      );
      controller.addReminder(newR);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar recordatorio' : 'Nuevo recordatorio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              const Text(
                'Fecha y hora',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(
                        _selectedTime.format(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Guardar cambios' : 'Crear recordatorio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
