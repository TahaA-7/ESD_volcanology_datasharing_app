import 'package:flutter/material.dart';
import '../models/timeline_models.dart';
import '../models/event_post_model.dart';

class TimelineController extends ChangeNotifier {
  TimelineRange _viewRange;
  final DateTime minDate;
  final DateTime maxDate;
  
  Event? _hoveredEvent;
  Offset? _mousePosition;

  TimelineController({
    DateTime? initialStart,
    DateTime? initialEnd,
    DateTime? minDate,
    DateTime? maxDate,
  })  : minDate = minDate ?? DateTime(2010, 1, 1),
        maxDate = maxDate ?? DateTime.now(),
        _viewRange = TimelineRange(
            start: initialStart ?? _getDefaultStart(),
            end: initialEnd ?? _getDefaultEnd(),
          );

  static DateTime _getDefaultStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 0, 0);
  }

  static DateTime _getDefaultEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  TimelineRange get viewRange => _viewRange;
  Event? get hoveredEvent => _hoveredEvent;
  Offset? get mousePosition => _mousePosition;

  bool get canGoPrevious => _viewRange.start.isAfter(minDate);
  bool get canGoNext => _viewRange.end.isBefore(maxDate);
  bool get isMultiDay => _viewRange.duration.inHours > 24;

  void setHover(Event? event, Offset? position) {
    if (_hoveredEvent != event || _mousePosition != position) {
      _hoveredEvent = event;
      _mousePosition = position;
      notifyListeners();
    }
  }

  void clearHover() {
    if (_hoveredEvent != null || _mousePosition != null) {
      _hoveredEvent = null;
      _mousePosition = null;
      notifyListeners();
    }
  }

  void goToPreviousDay() {
    if (canGoPrevious) {
      _viewRange = TimelineRange(
        start: _viewRange.start.subtract(const Duration(days: 1)),
        end: _viewRange.end.subtract(const Duration(days: 1)),
      );
      notifyListeners();
    }
  }

  void goToNextDay() {
    if (canGoNext) {
      _viewRange = TimelineRange(
        start: _viewRange.start.add(const Duration(days: 1)),
        end: _viewRange.end.add(const Duration(days: 1)),
      );
      notifyListeners();
    }
  }

  void goToToday() {
    _viewRange = TimelineRange(
      start: _getDefaultStart(),
      end: _getDefaultEnd(),
    );
    notifyListeners();
  }

  void zoomIn() {
    final duration = _viewRange.duration;
    if (duration.inHours > 12) {
      _viewRange = TimelineRange(
        start: _viewRange.start.add(const Duration(hours: 6)),
        end: _viewRange.end.subtract(const Duration(hours: 6)),
      );
      notifyListeners();
    }
  }

  void zoomOut() {
    _viewRange = TimelineRange(
      start: _viewRange.start.subtract(const Duration(days: 1)),
      end: _viewRange.end.add(const Duration(days: 1)),
    );
    notifyListeners();
  }

  void pan(double dragDelta, double timelineWidth) {
    final duration = _viewRange.duration;
    final dragRatio = -dragDelta / timelineWidth;
    final timeDelta = Duration(
      milliseconds: (duration.inMilliseconds * dragRatio).round(),
    );

    var newStart = _viewRange.start.add(timeDelta);
    var newEnd = _viewRange.end.add(timeDelta);

    if (newStart.isBefore(minDate)) {
      final diff = minDate.difference(newStart);
      newStart = minDate;
      newEnd = newEnd.add(diff);
    }
    if (newEnd.isAfter(maxDate)) {
      final diff = newEnd.difference(maxDate);
      newEnd = maxDate;
      newStart = newStart.subtract(diff);
    }

    _viewRange = TimelineRange(start: newStart, end: newEnd);
    notifyListeners();
  }

  void applyQuickTimeFilter(String timeFilter) {
    final now = DateTime.now();
    Duration duration;

    switch (timeFilter) {
      case '1h':
        duration = const Duration(hours: 1);
        break;
      case '3h':
        duration = const Duration(hours: 3);
        break;
      case '6h':
        duration = const Duration(hours: 6);
        break;
      case '12h':
        duration = const Duration(hours: 12);
        break;
      case '1d':
        duration = const Duration(days: 1);
        break;
      case '3d':
        duration = const Duration(days: 3);
        break;
      case '1w':
        duration = const Duration(days: 7);
        break;
      case '2w':
        duration = const Duration(days: 14);
        break;
      default:
        duration = const Duration(days: 1);
    }

    _viewRange = TimelineRange(
      start: now.subtract(duration),
      end: now,
    );
    notifyListeners();
  }

  void applyCustomDateFilter(DateTime? fromDate, DateTime? toDate) {
    DateTime start = fromDate ?? _viewRange.start;
    DateTime end = toDate ?? DateTime.now();

    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    _viewRange = TimelineRange(start: start, end: end);
    notifyListeners();
  }
}