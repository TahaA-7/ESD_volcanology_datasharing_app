import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../models/timeline_models.dart';

class TimelineGridPainter {
  final TimelineRange viewRange;

  TimelineGridPainter({required this.viewRange});

  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    if (_isMultiDay) {
      _paintMultiDayGrid(canvas, size, paint, textPainter);
    } else {
      _paintSingleDayGrid(canvas, size, paint, textPainter);
    }
  }

  bool get _isMultiDay => viewRange.duration.inHours > 24;

  void _paintSingleDayGrid(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    final hours = viewRange.duration.inHours + 1;
    final maxLabels = (size.width / TimelineConfig.minLabelWidth).floor();
    final interval = (hours / maxLabels).ceil().clamp(1, 24);
    final hourWidth = size.width / hours;

    for (int i = 0; i <= hours; i++) {
      final x = i * hourWidth;
      final currentTime = viewRange.start.add(Duration(hours: i));
      final isLabeled = i % interval == 0 || i == hours;

      paint.strokeWidth = isLabeled ? 1.5 : 0.5;

      canvas.drawLine(
        Offset(x, 0),
        Offset(
          x,
          isLabeled
              ? size.height - TimelineConfig.timelineBottomSpace
              : size.height - TimelineConfig.timelineBottomSpace - 10,
        ),
        paint,
      );

      if (isLabeled) {
        _paintTimeLabel(canvas, textPainter, currentTime, x, i, hours, size);
      }
    }

    _paintDateLabel(canvas, textPainter, size);
    _paintEndLabel(canvas, textPainter, size);
  }

  void _paintMultiDayGrid(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    final days = viewRange.duration.inDays + 1;
    final dayWidth = size.width / days;

    for (int i = 0; i <= days; i++) {
      final x = i * dayWidth;
      final currentDate = DateTime(
        viewRange.start.year,
        viewRange.start.month,
        viewRange.start.day + i,
      );

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - TimelineConfig.timelineBottomSpace),
        paint,
      );

      _paintDayLabel(canvas, textPainter, currentDate, x, size);

      if (i == 0) {
        _paintStartLabel(canvas, textPainter, size);
      }
      if (i == days) {
        _paintEndLabel(canvas, textPainter, size);
      }
    }

    _paintDateRangeLabel(canvas, textPainter, size);
  }

  void _paintTimeLabel(
    Canvas canvas,
    TextPainter textPainter,
    DateTime time,
    double x,
    int index,
    int totalHours,
    Size size,
  ) {
    textPainter.text = TextSpan(
      text: DateFormat('HH:mm').format(time),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 11,
      ),
    );
    textPainter.layout();

    double labelX = x - textPainter.width / 2;
    if (index == 0) labelX = 0;
    if (index == totalHours) labelX = size.width - textPainter.width;

    textPainter.paint(
      canvas,
      Offset(labelX, size.height - TimelineConfig.labelBottomOffset),
    );
  }

  void _paintDayLabel(
    Canvas canvas,
    TextPainter textPainter,
    DateTime date,
    double x,
    Size size,
  ) {
    textPainter.text = TextSpan(
      text: DateFormat('dd/MM').format(date),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, 
             size.height - TimelineConfig.labelBottomOffset),
    );
  }

  void _paintDateLabel(Canvas canvas, TextPainter textPainter, Size size) {
    textPainter.text = TextSpan(
      text: DateFormat('dd-MM-yyyy').format(viewRange.start),
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
        size.height - TimelineConfig.endLabelBottomOffset,
      ),
    );
  }

  void _paintDateRangeLabel(Canvas canvas, TextPainter textPainter, Size size) {
    final dateRangeText =
        '${DateFormat('dd-MM-yyyy').format(viewRange.start)} to '
        '${DateFormat('dd-MM-yyyy').format(viewRange.end)}';

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
        size.height - TimelineConfig.endLabelBottomOffset,
      ),
    );
  }

  void _paintStartLabel(Canvas canvas, TextPainter textPainter, Size size) {
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
      Offset(10, size.height - TimelineConfig.endLabelBottomOffset),
    );
  }

  void _paintEndLabel(Canvas canvas, TextPainter textPainter, Size size) {
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
      Offset(
        size.width - textPainter.width - 10,
        size.height - TimelineConfig.endLabelBottomOffset,
      ),
    );
  }
}