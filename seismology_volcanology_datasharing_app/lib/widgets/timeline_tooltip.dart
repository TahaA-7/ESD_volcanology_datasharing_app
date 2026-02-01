import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_post_model.dart';

class TimelineTooltip extends StatelessWidget {
  final Event event;

  const TimelineTooltip({
    super.key,
    required this.event,
  });

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.eventType.name.replaceAll('_', ' '),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            if (event.source.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Source: ${event.source}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            if (event.townCity.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Location: ${event.townCity}'
                '${event.country != Country.unspecified ? ', ${event.country.name}' : ''}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            if (event.startTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Time: ${dateFormat.format(event.startTime!)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            if (event.duration.inMinutes > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Duration: ${_formatDuration(event.duration)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}