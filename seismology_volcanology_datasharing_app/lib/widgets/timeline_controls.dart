import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/timeline_controller.dart';
import '../utils_services/responsive_sizes.dart';

class TimelineControls extends StatelessWidget {
  final TimelineController controller;

  const TimelineControls({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final horizontalPadding = ResponsiveSizes.getHorizontalPadding(context);
        final verticalPadding = ResponsiveSizes.getVerticalPadding(context);

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Container(
              color: Colors.grey[200],
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.canGoPrevious
                        ? controller.goToPreviousDay
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous Day',
                  ),
                  IconButton(
                    onPressed: controller.canGoNext
                        ? controller.goToNextDay
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next Day',
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: controller.goToToday,
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Today'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: controller.zoomOut,
                    icon: const Icon(Icons.zoom_out),
                    tooltip: 'Zoom Out',
                  ),
                  IconButton(
                    onPressed: controller.zoomIn,
                    icon: const Icon(Icons.zoom_in),
                    tooltip: 'Zoom In',
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      'Range: ${DateFormat('yyyy-MM-dd').format(controller.minDate)} '
                      'to ${DateFormat('yyyy-MM-dd').format(controller.maxDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}