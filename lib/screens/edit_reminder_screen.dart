import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';
import '../state/reminder_controller.dart';
import '../data/posturas.dart';

class EditReminderScreen extends StatefulWidget {
  final Reminder? existing;

  const EditReminderScreen({super.key, this.existing});

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime? _selectedDateTime;

  //  frecuencia y días personalizados
  ReminderFrequency _frequency = ReminderFrequency.once;
  int _customDays = 1;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _titleCtrl = TextEditingController(text: widget.existing!.title);
      _descCtrl = TextEditingController(text: widget.existing!.description);
      _selectedDateTime = widget.existing!.dateTime;
      _frequency = widget.existing!.frequency;
      _customDays = widget.existing!.customIntervalDays ?? 1;
    } else {
      final postura = ListaPosturas.items.first;
      _titleCtrl = TextEditingController(text: postura.titulo);
      _descCtrl = TextEditingController(text: postura.descripcion);
      _selectedDateTime = DateTime.now();
      _frequency = ReminderFrequency.once;
      _customDays = 1;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDateTime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Selecciona la fecha',
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'Selecciona la hora',
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Sin fecha seleccionada';

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
    final hora = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');

    return '$dia de $mes · $hora:$min hrs';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) return;

    final controller = context.read<ReminderController>();
    final id = widget.existing?.id ?? const Uuid().v4();

    final reminder = Reminder(
      id: id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dateTime: _selectedDateTime!,
      status: widget.existing?.status ?? ReminderStatus.pending,
      frequency: _frequency,
      customIntervalDays:
          _frequency == ReminderFrequency.custom ? _customDays : null,
    );

    if (isEditing) {
      await controller.updateReminder(reminder);
    } else {
      await controller.addReminder(reminder);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isEditing ? 'Editar recordatorio' : 'Nuevo recordatorio';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(
          titleText,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona una postura',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<PosturaItem>(
                  value: ListaPosturas.items.firstWhere(
                    (p) => p.titulo == _titleCtrl.text,
                    orElse: () => ListaPosturas.items.first,
                  ),
                  items: ListaPosturas.items.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(
                        p.titulo,
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                  onChanged: (postura) {
                    if (postura == null) return;
                    setState(() {
                      _titleCtrl.text = postura.titulo;
                      _descCtrl.text = postura.descripcion;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Título',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Ej: Estirar cuello',
                    hintStyle: const TextStyle(fontSize: 18),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe un título';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),
                const Text(
                  'Descripción (opcional)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ej: Girar hombros hacia atrás 10 veces',
                    hintStyle: const TextStyle(fontSize: 18),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //  FRECUENCIA
                const Text(
                  'Frecuencia',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<ReminderFrequency>(
                  value: _frequency,
                  items: const [
                    DropdownMenuItem(
                      value: ReminderFrequency.once,
                      child: Text("Una vez"),
                    ),
                    DropdownMenuItem(
                      value: ReminderFrequency.daily,
                      child: Text("Diario"),
                    ),
                    DropdownMenuItem(
                      value: ReminderFrequency.weekly,
                      child: Text("Semanal"),
                    ),
                    DropdownMenuItem(
                      value: ReminderFrequency.custom,
                      child: Text("Personalizado (cada N días)"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _frequency = value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                if (_frequency == ReminderFrequency.custom) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        "Cada ",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            hintText: 'Número de días',
                          ),
                          onChanged: (v) {
                            _customDays = int.tryParse(v) ?? 1;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "días",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 30),
                const Text(
                  'Fecha y hora',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _formatDateTime(_selectedDateTime),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.edit, size: 26),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _save,
                    child: Text(
                      isEditing ? 'Guardar cambios' : 'Crear recordatorio',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
