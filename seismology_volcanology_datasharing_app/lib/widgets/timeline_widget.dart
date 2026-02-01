import 'package:flutter/material.dart';
import '../models/event_post_model.dart';
import '../controllers/timeline_controller.dart';
import '../utils_services/timeline_layout_service.dart';
import '../painters/timeline_painter.dart';
import '../utils_services/responsive_sizes.dart';
import 'timeline_controls.dart';
import 'timeline_canvas.dart';

class TimelineWidget extends StatefulWidget {
  final DateTime? filterFromDate;
  final DateTime? filterToDate;
  final String? quickTimeFilter;
  final List<Event>? events;

  const TimelineWidget({
    super.key,
    this.filterFromDate,
    this.filterToDate,
    this.quickTimeFilter,
    this.events,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  late TimelineController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimelineController();
  }

  @override
  void didUpdateWidget(TimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.quickTimeFilter != null &&
        widget.quickTimeFilter != oldWidget.quickTimeFilter) {
      _controller.applyQuickTimeFilter(widget.quickTimeFilter!);
    } else if ((widget.filterFromDate != oldWidget.filterFromDate ||
            widget.filterToDate != oldWidget.filterToDate) &&
        (widget.filterFromDate != null || widget.filterToDate != null)) {
      _controller.applyCustomDateFilter(
        widget.filterFromDate,
        widget.filterToDate,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimelineControls(controller: _controller),
        Expanded(
          child: TimelineCanvas(
            controller: _controller,
            events: widget.events ?? const [],
          ),
        ),
      ],
    );
  }
}