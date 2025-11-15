import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/reminder_controller.dart';

class FilterButton extends StatelessWidget {
  final String text;
  final ReminderFilter filter;

  const FilterButton({
    super.key,
    required this.text,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReminderController>(context);
    final isSelected = controller.currentFilter == filter;

    return GestureDetector(
      onTap: () => controller.changeFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
