import 'package:flutter/material.dart';
import '../models/event_post_model.dart';
import '../controllers/timeline_controller.dart';
import '../utils_services/timeline_layout_service.dart';
import '../painters/timeline_painter.dart';
import 'event_details_dialog.dart';
import 'timeline_tooltip.dart';

class TimelineCanvas extends StatefulWidget {
  final TimelineController controller;
  final List<Event> events;

  const TimelineCanvas({
    super.key,
    required this.controller,
    required this.events,
  });

  @override
  State<TimelineCanvas> createState() => _TimelineCanvasState();
}

class _TimelineCanvasState extends State<TimelineCanvas> {
  double? _dragStartX;
  double? _dragStartTotalDelta;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return MouseRegion(
              onHover: (event) {
                final lanes = TimelineLayoutService.calculateEventLanes(
                  widget.events,
                  widget.controller.viewRange,
                  constraints.biggest,
                );
                final hoveredEvent = TimelineLayoutService.findEventAtPosition(
                  event.localPosition,
                  lanes,
                );
                widget.controller.setHover(hoveredEvent, event.localPosition);
              },
              onExit: (event) {
                widget.controller.clearHover();
              },
              child: Stack(
                children: [
                  GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: (details) => _onPanUpdate(
                      details,
                      constraints.maxWidth,
                    ),
                    onPanEnd: _onPanEnd,
                    onTapUp: (details) {
                      final lanes = TimelineLayoutService.calculateEventLanes(
                        widget.events,
                        widget.controller.viewRange,
                        constraints.biggest,
                      );
                      final event = TimelineLayoutService.findEventAtPosition(
                        details.localPosition,
                        lanes,
                      );
                      if (event != null) {
                        _showEventDetails(event);
                      }
                    },
                    child: CustomPaint(
                      painter: TimelinePainter(
                        viewRange: widget.controller.viewRange,
                        events: widget.events,
                        hoveredEvent: widget.controller.hoveredEvent,
                      ),
                      child: Container(),
                    ),
                  ),
                  if (widget.controller.hoveredEvent != null &&
                      widget.controller.mousePosition != null)
                    Positioned(
                      left: widget.controller.mousePosition!.dx + 15,
                      top: widget.controller.mousePosition!.dy - 10,
                      child: TimelineTooltip(
                        event: widget.controller.hoveredEvent!,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _dragStartTotalDelta = 0;
  }

  void _onPanUpdate(DragUpdateDetails details, double timelineWidth) {
    if (_dragStartX == null) return;

    final currentDelta = details.localPosition.dx - _dragStartX!;
    final deltaSinceLast = currentDelta - (_dragStartTotalDelta ?? 0);
    _dragStartTotalDelta = currentDelta;

    widget.controller.pan(deltaSinceLast, timelineWidth);
  }

  void _onPanEnd(DragEndDetails details) {
    _dragStartX = null;
    _dragStartTotalDelta = null;
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(event: event),
    );
  }
}