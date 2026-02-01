import 'package:flutter/material.dart';
import '../controllers/filter_controller.dart';
import '../models/filters_models.dart';

class TimeFiltersSection extends StatelessWidget {
  final FilterController controller;

  const TimeFiltersSection({
    super.key,
    required this.controller,
  });

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isFrom) {
        controller.setFromDate(picked);
      } else {
        controller.setToDate(picked);
      }
    }
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? '${date.day}-${date.month}-${date.year}'
                    : label,
                style: TextStyle(
                  fontSize: 11,
                  color: date != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Filters/Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text('Time Range', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 8),
            _dateField(
              context: context,
              label: 'From: [dd-mm-yy : hh-mm-ss...]',
              date: controller.state.fromDate,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 8),
            _dateField(
              context: context,
              label: 'Till: [Now (default)]',
              date: controller.state.toDate,
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: controller.resetTimeRange,
              icon: const Icon(Icons.refresh, size: 12),
              label: const Text('Reset to default', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Colors.grey[700],
              ),
            ),
          ],
        );
      },
    );
  }
}

class QuickTimeSection extends StatelessWidget {
  final FilterController controller;

  const QuickTimeSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View events from last:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '1h 3h 6h 12h 1d 3d 1w 2w',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: QuickTimeOptions.options.map((time) {
                final isSelected = controller.state.quickTimeFilter == time;
                return InkWell(
                  onTap: () => controller.setQuickTimeFilter(isSelected ? null : time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF868686) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF868686)
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class TimeAdjusterSection extends StatelessWidget {
  final FilterController controller;

  const TimeAdjusterSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Adjuster',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  thumbColor: Colors.blue,
                ),
                child: Slider(
                  value: controller.state.timeAdjusterValue,
                  onChanged: controller.setTimeAdjuster,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Period Shortener',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              '3h 14h 15h 16h 17h 18h 19h 20h 21h 22h 23h 1d',
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        );
      },
    );
  }
}

class SpatialFiltersSection extends StatelessWidget {
  final FilterController controller;

  const SpatialFiltersSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spatial Filters/Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        const Text(
          'Expand to see location, distance, and region filters',
          style: TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: controller.resetLocationFilters,
          icon: const Icon(Icons.refresh, size: 12),
          label: const Text('Reset to default', style: TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}