import 'package:flutter/material.dart';
import '../models/event_post_model.dart';
import '../models/timeline_models.dart';

class TimelineLayoutService {
  static List<EventLane> calculateEventLanes(
    List<Event> events,
    TimelineRange viewRange,
    Size canvasSize,
  ) {
    final durationMs = viewRange.duration.inMilliseconds;
    if (durationMs <= 0) return [];

    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) {
        final aDur = a.timeRange?.duration.inMilliseconds ?? 
                     a.duration.inMilliseconds;
        final bDur = b.timeRange?.duration.inMilliseconds ?? 
                     b.duration.inMilliseconds;
        return bDur.compareTo(aDur);
      });

    final List<DateTime?> laneEndTimes = [];
    final List<EventLane> lanes = [];

    for (var event in sortedEvents) {
      final timeInfo = _getEventTimeInfo(event, viewRange);
      if (timeInfo == null) continue;

      final rect = _calculateEventRect(
        timeInfo.visibleStart,
        timeInfo.visibleEnd,
        viewRange,
        canvasSize,
      );

      final laneIndex = _findAvailableLane(
        laneEndTimes,
        timeInfo.visibleStart,
      );

      final bounds = _getEventBounds(rect, laneIndex);

      lanes.add(EventLane(
        event: event,
        laneIndex: laneIndex,
        bounds: bounds,
      ));

      while (laneIndex >= laneEndTimes.length) {
        laneEndTimes.add(null);
      }
      laneEndTimes[laneIndex] = timeInfo.visibleEnd;
    }

    return lanes;
  }

  static Event? findEventAtPosition(
    Offset position,
    List<EventLane> lanes,
  ) {
    for (var lane in lanes) {
      if (lane.bounds.contains(position)) {
        return lane.event;
      }
    }
    return null;
  }

  static _EventTimeInfo? _getEventTimeInfo(
    Event event,
    TimelineRange viewRange,
  ) {
    DateTime? eventStart;
    DateTime? eventEnd;

    if (event.timeRange != null) {
      eventStart = event.timeRange!.start;
      eventEnd = event.timeRange!.end;
    } else if (event.startTime != null) {
      eventStart = event.startTime;
      eventEnd = event.startTime!.add(event.duration);
    }

    if (eventStart == null || eventEnd == null) return null;
    if (eventEnd.isBefore(viewRange.start) || 
        eventStart.isAfter(viewRange.end)) return null;

    final visibleStart = eventStart.isBefore(viewRange.start)
        ? viewRange.start
        : eventStart;
    final visibleEnd = eventEnd.isAfter(viewRange.end)
        ? viewRange.end
        : eventEnd;

    return _EventTimeInfo(
      visibleStart: visibleStart,
      visibleEnd: visibleEnd,
    );
  }

  static Rect _calculateEventRect(
    DateTime visibleStart,
    DateTime visibleEnd,
    TimelineRange viewRange,
    Size canvasSize,
  ) {
    final durationMs = viewRange.duration.inMilliseconds;
    final startRatio = visibleStart.difference(viewRange.start).inMilliseconds / 
                      durationMs;
    final endRatio = visibleEnd.difference(viewRange.start).inMilliseconds / 
                    durationMs;

    final x = (startRatio * canvasSize.width).clamp(0.0, canvasSize.width);
    final width = ((endRatio - startRatio) * canvasSize.width)
        .clamp(2.0, canvasSize.width - x);

    return Rect.fromLTWH(x, 0, width, TimelineConfig.barHeight);
  }

  static int _findAvailableLane(
    List<DateTime?> laneEndTimes,
    DateTime eventStart,
  ) {
    int laneIndex = 0;
    while (laneIndex < laneEndTimes.length) {
      if (laneEndTimes[laneIndex] == null ||
          laneEndTimes[laneIndex]!.isBefore(eventStart)) {
        break;
      }
      laneIndex++;
    }
    return laneIndex;
  }

  static Rect _getEventBounds(Rect rect, int laneIndex) {
    final y = TimelineConfig.topPadding +
        (laneIndex * (TimelineConfig.barHeight + TimelineConfig.verticalSpacing));

    return Rect.fromLTWH(rect.left, y, rect.width, TimelineConfig.barHeight);
  }
}

class _EventTimeInfo {
  final DateTime visibleStart;
  final DateTime visibleEnd;

  _EventTimeInfo({
    required this.visibleStart,
    required this.visibleEnd,
  });
}