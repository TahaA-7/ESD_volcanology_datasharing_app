import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/event_post_model.dart';
import '../models/timeline_models.dart';
import '../utils_services/timeline_layout_service.dart';
import '../utils_services/event_color_helper.dart';

class TimelineEventsPainter {
  final TimelineRange viewRange;
  final List<Event> events;
  final Event? hoveredEvent;

  TimelineEventsPainter({
    required this.viewRange,
    required this.events,
    this.hoveredEvent,
  });

  void paint(Canvas canvas, Size size) {
    final lanes = TimelineLayoutService.calculateEventLanes(
      events,
      viewRange,
      size,
    );

    for (var lane in lanes) {
      _paintEvent(canvas, lane, size);
    }
  }

  void _paintEvent(Canvas canvas, EventLane lane, Size size) {
    final isHovered = hoveredEvent == lane.event;
    final baseColor = EventColorHelper.getColorForEventType(lane.event.eventType);

    // Fill
    final paint = Paint()
      ..color = isHovered ? baseColor : baseColor.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      lane.bounds,
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, paint);

    // Border
    final borderPaint = Paint()
      ..color = isHovered ? Colors.white : baseColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 2.5 : 1.5;

    canvas.drawRRect(rect, borderPaint);

    // Label
    if (lane.bounds.width > 40) {
      _paintEventLabel(canvas, lane);
    }
  }

  void _paintEventLabel(Canvas canvas, EventLane lane) {
    final labelSource = lane.event.source.isNotEmpty
        ? lane.event.source
        : lane.event.description;
    final label = labelSource.isNotEmpty
        ? labelSource
        : lane.event.eventType.name;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label.length > 30 ? '${label.substring(0, 28)}…' : label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout(maxWidth: lane.bounds.width - 8);

    if (textPainter.width < lane.bounds.width - 8) {
      textPainter.paint(
        canvas,
        Offset(
          lane.bounds.left + 4,
          lane.bounds.top + (lane.bounds.height - textPainter.height) / 2,
        ),
      );
    }
  }
}