import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../models/event_post_model.dart';
import '../models/timeline_models.dart';
import '../utils_services/timeline_layout_service.dart';
import 'timeline_grid_painter.dart';
import 'timeline_events_painter.dart';

class TimelinePainter extends CustomPainter {
  final TimelineRange viewRange;
  final List<Event> events;
  final Event? hoveredEvent;

  TimelinePainter({
    required this.viewRange,
    this.events = const [],
    this.hoveredEvent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPainter = TimelineGridPainter(viewRange: viewRange);
    gridPainter.paint(canvas, size);
    
    if (events.isNotEmpty) {
      final eventsPainter = TimelineEventsPainter(
        viewRange: viewRange,
        events: events,
        hoveredEvent: hoveredEvent,
      );
      eventsPainter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    if (oldDelegate.viewRange.start != viewRange.start ||
        oldDelegate.viewRange.end != viewRange.end) return true;
    if (oldDelegate.hoveredEvent != hoveredEvent) return true;
    
    final oldIds = oldDelegate.events.map((e) => e.id).join(',');
    final newIds = events.map((e) => e.id).join(',');
    return oldIds != newIds;
  }
}