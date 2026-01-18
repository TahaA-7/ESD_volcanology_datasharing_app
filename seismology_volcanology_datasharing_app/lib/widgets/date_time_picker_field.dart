import 'package:flutter/material.dart';

class DateTimePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool isError;
  final ValueChanged<DateTime?> onChanged;

  const DateTimePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isError = false,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(0),
      lastDate: DateTime(3000),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: value != null
          ? TimeOfDay.fromDateTime(value!)
          : TimeOfDay.fromDateTime(now),
    );

    if (time == null) return;

    onChanged(DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final displayText = value == null
        ? label
        : '${value!.toLocal()}'.substring(0, 16);

    return InkWell(
      onTap: () => _pickDateTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError ? const Color(0xFFE89B9B) : const Color(0xFF8C8B9E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText,
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
