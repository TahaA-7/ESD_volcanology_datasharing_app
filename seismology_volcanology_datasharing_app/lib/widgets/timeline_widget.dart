import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// Use existing event post model (no changes to model)
import '../models/event_post_model.dart';

class TimelineWidget extends StatefulWidget {
  final DateTime? filterFromDate;
  final DateTime? filterToDate;
  final String? quickTimeFilter;
  final List<Event>? events; // posted events to display

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
  late DateTime _startTime;
  late DateTime _endTime;
  late DateTime _minDate;
  late DateTime _maxDate;
  final ScrollController _scrollController = ScrollController();

  double? _dragStartX;
  DateTime? _dragStartTime;
  DateTime? _dragEndTime;

  @override
  void initState() {
    super.initState();
    // Set the absolute range: 2010 to now
    _minDate = DateTime(2010, 1, 1);
    _maxDate = DateTime.now();

    // Initialize to show today by default
    _initializeToday();
  }

  @override
  void didUpdateWidget(TimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Apply filters when they change
    if (widget.quickTimeFilter != null &&
        widget.quickTimeFilter != oldWidget.quickTimeFilter) {
      _applyQuickTimeFilter(widget.quickTimeFilter!);
    } else if ((widget.filterFromDate != oldWidget.filterFromDate ||
            widget.filterToDate != oldWidget.filterToDate) &&
        (widget.filterFromDate != null || widget.filterToDate != null)) {
      _applyCustomDateFilter();
    }

    // If events reference changed, trigger repaint by calling setState
    if (widget.events != oldWidget.events) {
      setState(() {});
    }
  }

  void _applyQuickTimeFilter(String timeFilter) {
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
      default:
        duration = const Duration(days: 1);
    }

    setState(() {
      _endTime = now;
      _startTime = now.subtract(duration);
    });
  }

  void _applyCustomDateFilter() {
    setState(() {
      if (widget.filterFromDate != null) {
        _startTime = widget.filterFromDate!;
      }
      if (widget.filterToDate != null) {
        _endTime = widget.filterToDate!;
      } else {
        // If no end date specified, use now
        _endTime = DateTime.now();
      }

      // Ensure we have a valid range
      if (_startTime.isAfter(_endTime)) {
        final temp = _startTime;
        _startTime = _endTime;
        _endTime = temp;
      }
    });
  }

  void _initializeToday() {
    final now = DateTime.now();
    // Start at beginning of today
    _startTime = DateTime(now.year, now.month, now.day, 0, 0);
    // End at end of today
    _endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void _goToPreviousDay() {
    if (_startTime.isAfter(_minDate)) {
      setState(() {
        _startTime = _startTime.subtract(const Duration(days: 1));
        _endTime = _endTime.subtract(const Duration(days: 1));
      });
    }
  }

  void _goToNextDay() {
    if (_endTime.isBefore(_maxDate)) {
      setState(() {
        _startTime = _startTime.add(const Duration(days: 1));
        _endTime = _endTime.add(const Duration(days: 1));
      });
    }
  }

  void _goToToday() {
    setState(() {
      _initializeToday();
    });
  }

  void _zoomOut() {
    // Show more time range (e.g., 3 days)
    setState(() {
      _startTime = _startTime.subtract(const Duration(days: 1));
      _endTime = _endTime.add(const Duration(days: 1));
    });
  }

  void _zoomIn() {
    // Show less time range
    final duration = _endTime.difference(_startTime);
    if (duration.inHours > 12) {
      setState(() {
        _startTime = _startTime.add(const Duration(hours: 6));
        _endTime = _endTime.subtract(const Duration(hours: 6));
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _dragStartTime = _startTime;
    _dragEndTime = _endTime;
  }

  void _onPanUpdate(DragUpdateDetails details, double timelineWidth) {
    if (_dragStartX == null || _dragStartTime == null || _dragEndTime == null) return;

    final dragDelta = details.localPosition.dx - _dragStartX!;
    final duration = _dragEndTime!.difference(_dragStartTime!);

    // Calculate how much time the drag represents
    final dragRatio = -dragDelta / timelineWidth; // Negative so dragging right goes back in time
    final timeDelta = Duration(milliseconds: (duration.inMilliseconds * dragRatio).round());

    var newStart = _dragStartTime!.add(timeDelta);
    var newEnd = _dragEndTime!.add(timeDelta);

    // Clamp to min/max dates
    if (newStart.isBefore(_minDate)) {
      final diff = _minDate.difference(newStart);
      newStart = _minDate;
      newEnd = newEnd.add(diff);
    }
    if (newEnd.isAfter(_maxDate)) {
      final diff = newEnd.difference(_maxDate);
      newEnd = _maxDate;
      newStart = newStart.subtract(diff);
    }

    setState(() {
      _startTime = newStart;
      _endTime = newEnd;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _dragStartX = null;
    _dragStartTime = null;
    _dragEndTime = null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = _startTime.isAfter(_minDate);
    final canGoNext = _endTime.isBefore(_maxDate);

    return Column(
      children: [
        // Navigation controls
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Row(
            children: [
              IconButton(
                onPressed: canGoPrevious ? _goToPreviousDay : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous Day',
              ),
              IconButton(
                onPressed: canGoNext ? _goToNextDay : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next Day',
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _goToToday,
                icon: const Icon(Icons.today, size: 18),
                label: const Text('Today'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _zoomOut,
                icon: const Icon(Icons.zoom_out),
                tooltip: 'Zoom Out',
              ),
              IconButton(
                onPressed: _zoomIn,
                icon: const Icon(Icons.zoom_in),
                tooltip: 'Zoom In',
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Range: ${DateFormat('yyyy-MM-dd').format(_minDate)} to ${DateFormat('yyyy-MM-dd').format(_maxDate)}',
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
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: (details) => _onPanUpdate(details, constraints.maxWidth),
                onPanEnd: _onPanEnd,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: CustomPaint(
                    painter: TimelinePainter(
                      startTime: _startTime,
                      endTime: _endTime,
                      events: widget.events ?? const [],
                    ),
                    child: Container(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TimelinePainter extends CustomPainter {
  final DateTime startTime;
  final DateTime endTime;
  final List<Event> events;

  TimelinePainter({
    required this.startTime,
    required this.endTime,
    this.events = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate time span
    final duration = endTime.difference(startTime);
    final isMultiDay = duration.inHours > 24;

    // Draw timeline background - WHITE
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    if (isMultiDay) {
      _drawMultiDayTimeline(canvas, size, paint, textPainter);
    } else {
      _drawSingleDayTimeline(canvas, size, paint, textPainter);
    }

    // Draw posted events (fallback to sample if none)
    if (events.isNotEmpty) {
      _drawEvents(canvas, size, textPainter);
    // } else {
    //   _drawSampleEvents(canvas, size);
    }
  }

  void _drawSingleDayTimeline(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours + 1;
    final hourWidth = size.width / hours;

    // Draw hour markers and labels
    for (int i = 0; i <= hours; i++) {
      final x = i * hourWidth;
      final currentTime = startTime.add(Duration(hours: i));

      // Draw vertical line
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - 60),
        paint,
      );

      // Draw hour label (BOTTOM)
      final hourText = DateFormat('HH:mm').format(currentTime);
      textPainter.text = TextSpan(
        text: hourText,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 55),
      );

      // Draw "start" label at beginning
      if (i == 0) {
        textPainter.text = const TextSpan(
          text: 'start',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(10, size.height - 30),
        );
      }

      // Draw "end" label at end
      if (i == hours) {
        textPainter.text = const TextSpan(
          text: 'end',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width - textPainter.width - 10, size.height - 30),
        );
      }
    }

    // Draw date label at bottom center
    final dateText = DateFormat('dd-MM-yyyy').format(startTime);
    textPainter.text = TextSpan(
      text: dateText,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height - 30,
      ),
    );
  }

  void _drawMultiDayTimeline(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    final duration = endTime.difference(startTime);
    final days = duration.inDays + 1;
    final dayWidth = size.width / days;

    // Draw day markers and labels
    for (int i = 0; i <= days; i++) {
      final x = i * dayWidth;
      final currentDate = DateTime(
        startTime.year,
        startTime.month,
        startTime.day + i,
      );

      // Draw vertical line
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - 60),
        paint,
      );

      // Draw date label (BOTTOM)
      final dateText = DateFormat('dd/MM').format(currentDate);
      textPainter.text = TextSpan(
        text: dateText,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 55),
      );

      // Draw "start" label at beginning
      if (i == 0) {
        textPainter.text = const TextSpan(
          text: 'start',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(10, size.height - 30),
        );
      }

      // Draw "end" label at end
      if (i == days) {
        textPainter.text = const TextSpan(
          text: 'end',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width - textPainter.width - 10, size.height - 30),
        );
      }
    }

    // Draw date range at bottom center
    final dateRangeText = '${DateFormat('dd-MM-yyyy').format(startTime)} to ${DateFormat('dd-MM-yyyy').format(endTime)}';
    textPainter.text = TextSpan(
      text: dateRangeText,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height - 30,
      ),
    );
  }

  void _drawSampleEvents(Canvas canvas, Size size) {
    final eventPaint = Paint()..color = Colors.grey.shade500;

    // Calculate time span for positioning events
    final duration = endTime.difference(startTime);
    final totalHours = max(1, duration.inHours); 

    // Sample events at different times
    final sample = [
      {'start': 2, 'duration': 1.5, 'y': 0.3},
      {'start': 4, 'duration': 0.8, 'y': 0.4},
      {'start': 6, 'duration': 2.0, 'y': 0.25},
      {'start': 10, 'duration': 1.2, 'y': 0.35},
      {'start': 14, 'duration': 0.5, 'y': 0.45},
      {'start': 16, 'duration': 1.8, 'y': 0.3},
      {'start': 19, 'duration': 1.0, 'y': 0.4},
    ];

    for (var event in sample) {
      final startHour = event['start'] as num;
      final eventDuration = event['duration'] as num;
      final yPosition = event['y'] as num;

      // Only draw events that fit within current time range
      if (startHour < totalHours) {
        final x = (startHour / totalHours) * size.width;
        final width = (eventDuration / totalHours) * size.width;
        final y = size.height * yPosition;
        final height = 20.0;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, width, height),
            const Radius.circular(4),
          ),
          eventPaint,
        );
      }
    }
  }

  Color _colorForEventType(EventType t) {
    switch (t) {
      case EventType.seismic_tectonic:
        return Colors.deepOrange;
      case EventType.volcanicEruptive_surfaceProcess:
      case EventType.volcanicNonEruptive:
        return Colors.redAccent;
      case EventType.massMovement_surfaceInstability:
        return Colors.brown;
      case EventType.hydrothermal_fluidDriven:
        return Colors.teal;
      case EventType.cryoseismic_glacial:
        return Colors.lightBlue;
      case EventType.atmospheric_coupledSignals:
        return Colors.indigo;
      case EventType.anthropogenic:
        return Colors.purple;
      case EventType.geodetic_deformation:
        return Colors.green;
      default:
        return Colors.grey.shade700;
    }
  }

  void _drawEvents(Canvas canvas, Size size, TextPainter textPainter) {
    final durationMs = endTime.difference(startTime).inMilliseconds;
    if (durationMs <= 0) return;

    // Sort events by duration (longest first) so they render behind shorter ones
    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) {
        final aDur = a.timeRange?.duration.inMilliseconds ?? a.duration.inMilliseconds;
        final bDur = b.timeRange?.duration.inMilliseconds ?? b.duration.inMilliseconds;
        return bDur.compareTo(aDur); // longest first
      });

    final double topPadding = 20;
    final double barHeight = 24;
    final double verticalSpacing = 4;
    
    // Track vertical lanes to avoid overlap
    final List<DateTime?> laneEndTimes = [];

    for (var ev in sortedEvents) {
      // Get event start and end times
      DateTime? eventStart;
      DateTime? eventEnd;
      
      if (ev.timeRange != null) {
        eventStart = ev.timeRange!.start;
        eventEnd = ev.timeRange!.end;
      } else if (ev.startTime != null) {
        eventStart = ev.startTime;
        eventEnd = ev.startTime!.add(ev.duration);
      }
      
      if (eventStart == null || eventEnd == null) continue;
      if (eventEnd.isBefore(startTime) || eventStart.isAfter(endTime)) continue;

      // Clamp to visible range
      final visibleStart = eventStart.isBefore(startTime) ? startTime : eventStart;
      final visibleEnd = eventEnd.isAfter(endTime) ? endTime : eventEnd;

      // Calculate positions
      final startRatio = visibleStart.difference(startTime).inMilliseconds / durationMs;
      final endRatio = visibleEnd.difference(startTime).inMilliseconds / durationMs;
      
      final x = (startRatio * size.width).clamp(0.0, size.width);
      final width = ((endRatio - startRatio) * size.width).clamp(2.0, size.width - x);

      // Find available lane (vertical position)
      int laneIndex = 0;
      while (laneIndex < laneEndTimes.length) {
        if (laneEndTimes[laneIndex] == null || 
            laneEndTimes[laneIndex]!.isBefore(visibleStart)) {
          break;
        }
        laneIndex++;
      }
      
      // Ensure we have enough lanes
      while (laneIndex >= laneEndTimes.length) {
        laneEndTimes.add(null);
      }
      
      laneEndTimes[laneIndex] = visibleEnd;
      
      final y = topPadding + (laneIndex * (barHeight + verticalSpacing));

      // Draw event bar
      final paint = Paint()
        ..color = _colorForEventType(ev.eventType)
        ..style = PaintingStyle.fill;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, barHeight),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(rect, paint);

      // Draw border
      final borderPaint = Paint()
        ..color = _colorForEventType(ev.eventType).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(rect, borderPaint);

      // Draw label if there's enough space
      if (width > 40) {
        final labelSource = (ev.source.isNotEmpty ? ev.source : ev.description);
        final label = (labelSource.isNotEmpty ? labelSource : ev.eventType.name);
        
        textPainter.text = TextSpan(
          text: label.length > 30 ? label.substring(0, 28) + '…' : label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
        );
        textPainter.layout(maxWidth: width - 8);
        
        if (textPainter.width < width - 8) {
          textPainter.paint(
            canvas,
            Offset(x + 4, y + (barHeight - textPainter.height) / 2),
          );
        }
      }
    }
  }


  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    if (oldDelegate.startTime != startTime || oldDelegate.endTime != endTime) return true;
    // compare event ids to decide repaint
    final oldIds = oldDelegate.events.map((e) => e.id).join(',');
    final newIds = events.map((e) => e.id).join(',');
    return oldIds != newIds;
  }
}