import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../models/event_post_model.dart';
import 'event_details_dialog.dart';
import '../utils_services/responsive_sizes.dart';

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
  late DateTime _startTime;
  late DateTime _endTime;
  late DateTime _minDate;
  late DateTime _maxDate;
  final ScrollController _scrollController = ScrollController();

  double? _dragStartX;
  DateTime? _dragStartTime;
  DateTime? _dragEndTime;

  // Hover state
  Offset? _mousePosition;
  Event? _hoveredEvent;

  @override
  void initState() {
    super.initState();
    _minDate = DateTime(2010, 1, 1);
    _maxDate = DateTime.now();
    _initializeToday();
  }

  @override
  void didUpdateWidget(TimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.quickTimeFilter != null &&
        widget.quickTimeFilter != oldWidget.quickTimeFilter) {
      _applyQuickTimeFilter(widget.quickTimeFilter!);
    } else if ((widget.filterFromDate != oldWidget.filterFromDate ||
            widget.filterToDate != oldWidget.filterToDate) &&
        (widget.filterFromDate != null || widget.filterToDate != null)) {
      _applyCustomDateFilter();
    }

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
        _endTime = DateTime.now();
      }

      if (_startTime.isAfter(_endTime)) {
        final temp = _startTime;
        _startTime = _endTime;
        _endTime = temp;
      }
    });
  }

  void _initializeToday() {
    final now = DateTime.now();
    _startTime = DateTime(now.year, now.month, now.day, 0, 0);
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
    setState(() {
      _startTime = _startTime.subtract(const Duration(days: 1));
      _endTime = _endTime.add(const Duration(days: 1));
    });
  }

  void _zoomIn() {
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

    final dragRatio = -dragDelta / timelineWidth;
    final timeDelta = Duration(milliseconds: (duration.inMilliseconds * dragRatio).round());

    var newStart = _dragStartTime!.add(timeDelta);
    var newEnd = _dragEndTime!.add(timeDelta);

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
    final horizontalPadding = ResponsiveSizes.getHorizontalPadding(context);
    final verticalPadding = ResponsiveSizes.getVerticalPadding(context);
    final contentSpacing = ResponsiveSizes.getContentSpacing(context);

    final canGoPrevious = _startTime.isAfter(_minDate);
    final canGoNext = _endTime.isBefore(_maxDate);

    return Column(
      children: [
        SafeArea(
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
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                onHover: (event) {
                  setState(() {
                    _mousePosition = event.localPosition;
                    _hoveredEvent = _getEventAtPosition(event.localPosition, constraints.biggest);
                  });
                },
                onExit: (event) {
                  setState(() {
                    _mousePosition = null;
                    _hoveredEvent = null;
                  });
                },
                child: Stack(
                  children: [
                    GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: (details) => _onPanUpdate(details, constraints.maxWidth),
                      onPanEnd: _onPanEnd,
                      onTapUp: (details) {
                        final event = _getEventAtPosition(details.localPosition, constraints.biggest);
                        if (event != null) {
                          _showEventDetails(event);
                        }
                      },
                      child: CustomPaint(
                        painter: TimelinePainter(
                          startTime: _startTime,
                          endTime: _endTime,
                          events: widget.events ?? const [],
                          hoveredEvent: _hoveredEvent,
                        ),
                        child: Container(),
                      ),
                    ),
                    if (_hoveredEvent != null && _mousePosition != null)
                      Positioned(
                        left: _mousePosition!.dx + 15,
                        top: _mousePosition!.dy - 10,
                        child: _buildTooltip(_hoveredEvent!),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Event? _getEventAtPosition(Offset position, Size size) {
    final durationMs = _endTime.difference(_startTime).inMilliseconds;
    if (durationMs <= 0) return null;

    final double topPadding = 20;
    final double barHeight = 24;
    final double verticalSpacing = 4;

    final sortedEvents = List<Event>.from(widget.events ?? [])
      ..sort((a, b) {
        final aDur = a.timeRange?.duration.inMilliseconds ?? a.duration.inMilliseconds;
        final bDur = b.timeRange?.duration.inMilliseconds ?? b.duration.inMilliseconds;
        return bDur.compareTo(aDur);
      });

    final List<DateTime?> laneEndTimes = [];

    for (var ev in sortedEvents) {
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
      if (eventEnd.isBefore(_startTime) || eventStart.isAfter(_endTime)) continue;

      final visibleStart = eventStart.isBefore(_startTime) ? _startTime : eventStart;
      final visibleEnd = eventEnd.isAfter(_endTime) ? _endTime : eventEnd;

      final startRatio = visibleStart.difference(_startTime).inMilliseconds / durationMs;
      final endRatio = visibleEnd.difference(_startTime).inMilliseconds / durationMs;
      
      final x = (startRatio * size.width).clamp(0.0, size.width);
      final width = ((endRatio - startRatio) * size.width).clamp(2.0, size.width - x);

      int laneIndex = 0;
      while (laneIndex < laneEndTimes.length) {
        if (laneEndTimes[laneIndex] == null || 
            laneEndTimes[laneIndex]!.isBefore(visibleStart)) {
          break;
        }
        laneIndex++;
      }
      
      while (laneIndex >= laneEndTimes.length) {
        laneEndTimes.add(null);
      }
      
      laneEndTimes[laneIndex] = visibleEnd;
      
      final y = topPadding + (laneIndex * (barHeight + verticalSpacing));

      final rect = Rect.fromLTWH(x, y, width, barHeight);
      if (rect.contains(position)) {
        return ev;
      }
    }

    return null;
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(event: event),
    );
  }

  Widget _buildTooltip(Event event) {
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
                'Location: ${event.townCity}${event.country != Country.unspecified ? ', ${event.country.name}' : ''}',
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

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

class TimelinePainter extends CustomPainter {
  final DateTime startTime;
  final DateTime endTime;
  final List<Event> events;
  final Event? hoveredEvent;

  TimelinePainter({
    required this.startTime,
    required this.endTime,
    this.events = const [],
    this.hoveredEvent,
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

    final duration = endTime.difference(startTime);
    final isMultiDay = duration.inHours > 24;

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

    if (events.isNotEmpty) {
      _drawEvents(canvas, size, textPainter);
    }
  }

  void _drawSingleDayTimeline(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours + 1;

    // otherwise it becomes too cramped on mobile
    const double minLabelWidth = 50.0;
    final int maxLabels = (size.width / minLabelWidth).floor();

    final int interval = (hours / maxLabels).ceil().clamp(1, 24);

    final hourWidth = size.width / hours;
    //

    for (int i = 0; i <= hours; i++) {
      final x = i * hourWidth;
      final currentTime = startTime.add(Duration(hours: i));

      final isLabeled = i % interval == 0 || i == hours;
      paint.strokeWidth = isLabeled ? 1.5 : 0.5;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, isLabeled ? size.height - 60 : size.height - 70),
        paint,
      );

      if (isLabeled) {
        final hourText = DateFormat('HH:mm').format(currentTime);
        textPainter.text = TextSpan(
          text: hourText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            // fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();

        double labelX = x - textPainter.width / 2;
        if (i == 0) labelX = 0;
        if (i == hours) labelX = size.width - textPainter.width;

        textPainter.paint(canvas, Offset(labelX, size.height - 55),
        );
      }

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

    for (int i = 0; i <= days; i++) {
      final x = i * dayWidth;
      final currentDate = DateTime(
        startTime.year,
        startTime.month,
        startTime.day + i,
      );

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - 60),
        paint,
      );

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

    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) {
        final aDur = a.timeRange?.duration.inMilliseconds ?? a.duration.inMilliseconds;
        final bDur = b.timeRange?.duration.inMilliseconds ?? b.duration.inMilliseconds;
        return bDur.compareTo(aDur);
      });

    final double topPadding = 20;
    final double barHeight = 24;
    final double verticalSpacing = 4;
    
    final List<DateTime?> laneEndTimes = [];

    for (var ev in sortedEvents) {
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

      final visibleStart = eventStart.isBefore(startTime) ? startTime : eventStart;
      final visibleEnd = eventEnd.isAfter(endTime) ? endTime : eventEnd;

      final startRatio = visibleStart.difference(startTime).inMilliseconds / durationMs;
      final endRatio = visibleEnd.difference(startTime).inMilliseconds / durationMs;
      
      final x = (startRatio * size.width).clamp(0.0, size.width);
      final width = ((endRatio - startRatio) * size.width).clamp(2.0, size.width - x);

      int laneIndex = 0;
      while (laneIndex < laneEndTimes.length) {
        if (laneEndTimes[laneIndex] == null || 
            laneEndTimes[laneIndex]!.isBefore(visibleStart)) {
          break;
        }
        laneIndex++;
      }
      
      while (laneIndex >= laneEndTimes.length) {
        laneEndTimes.add(null);
      }
      
      laneEndTimes[laneIndex] = visibleEnd;
      
      final y = topPadding + (laneIndex * (barHeight + verticalSpacing));

      final isHovered = hoveredEvent == ev;
      final baseColor = _colorForEventType(ev.eventType);
      
      final paint = Paint()
        ..color = isHovered ? baseColor : baseColor.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, barHeight),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(rect, paint);

      final borderPaint = Paint()
        ..color = isHovered ? Colors.white : baseColor.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? 2.5 : 1.5;
      canvas.drawRRect(rect, borderPaint);

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
    if (oldDelegate.hoveredEvent != hoveredEvent) return true;
    final oldIds = oldDelegate.events.map((e) => e.id).join(',');
    final newIds = events.map((e) => e.id).join(',');
    return oldIds != newIds;
  }
}