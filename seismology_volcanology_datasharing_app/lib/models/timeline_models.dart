import 'package:flutter/material.dart';
import 'event_post_model.dart';

class TimelineRange {
  final DateTime start;
  final DateTime end;

  TimelineRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  TimelineRange copyWith({DateTime? start, DateTime? end}) {
    return TimelineRange(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class TimelineConfig {
  static const double topPadding = 20.0;
  static const double barHeight = 24.0;
  static const double verticalSpacing = 4.0;
  static const double minLabelWidth = 50.0;
  static const double timelineBottomSpace = 60.0;
  static const double labelBottomOffset = 55.0;
  static const double endLabelBottomOffset = 30.0;
}

class EventLane {
  final Event event;
  final int laneIndex;
  final Rect bounds;

  EventLane({
    required this.event,
    required this.laneIndex,
    required this.bounds,
  });
}