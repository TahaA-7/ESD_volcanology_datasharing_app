import 'package:flutter/material.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  Widget _radioOption(String label) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: '',
          onChanged: (value) {},
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('aggregation', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {},
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Expanded(
                        child: Text(
                          'aggregate only events that are visible with current zoom',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('order by', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  _radioOption('date-time'),
                  _radioOption('duration'),
                  _radioOption('event type (seismic first, false/test last)'),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('order by', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  _radioOption('descending'),
                  _radioOption('ascending'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}