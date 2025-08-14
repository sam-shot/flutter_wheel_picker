import 'dart:math' as math;

import 'package:flutter/material.dart';

class WheelPickerPainter extends CustomPainter {
  final double minValue;
  final double maxValue;
  final double currentValue;
  final double radius;

  WheelPickerPainter({
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final center = Offset(width / 2, height / 2);
    final radius = this.radius;

    final arcPaint =
        Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 50;

    final tickPaint =
        Paint()
          ..color = Colors.grey.shade500
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3;

    final pointerPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final pointerThumbPaint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi;
    const sweepAngle = math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    /// TICKS
    final visibleRange = 25;
    final currentValueRounded = currentValue.round();

    // Only draw ticks if current value is non-negative
    if (currentValue >= 0) {
      final startValue = math.max(minValue, currentValueRounded - visibleRange);
      final endValue = math.min(maxValue, currentValueRounded + visibleRange);

      for (int i = startValue.toInt(); i <= endValue; i++) {
        // Calculate the angle for this value relative to current value
        final valueOffset = i - currentValue;
        final tickSpacing = 0.1; // Angular spacing between ticks
        final angle = -math.pi / 2 + (valueOffset * tickSpacing);

        // Only draw ticks that are within the semicircle
        if (angle >= (-math.pi - 0.15) && angle <= 0.15) {
          // Determine tick length
          final tickLength = (i % 10 == 0) ? 30 : 15;

          // Calculate tick positions
          final innerPoint = Offset(
            center.dx + (radius - 23) * math.cos(angle),
            center.dy + (radius - 23) * math.sin(angle),
          );
          final outerPoint = Offset(
            center.dx + (radius - 23 + tickLength) * math.cos(angle),
            center.dy + (radius - 23 + tickLength) * math.sin(angle),
          );

          canvas.drawLine(innerPoint, outerPoint, tickPaint);
        }
      }
    } else {
      // For negative values, draw ticks starting from minValue but offset to the right
      final startValue = minValue;
      final endValue = math.min(maxValue, minValue + visibleRange * 2);

      for (int i = startValue.toInt(); i <= endValue; i++) {
        // Offset the angle calculation to move ticks to the right
        final valueOffset = i - minValue + currentValue.abs();
        final tickSpacing = 0.1;
        final angle = -math.pi / 2 + (valueOffset * tickSpacing);

        // Only draw ticks that are within the semicircle
        if (angle >= (-math.pi - 0.15) && angle <= 0.15) {
          final tickLength = (i % 10 == 0) ? 30 : 15;

          final innerPoint = Offset(
            center.dx + (radius - 23) * math.cos(angle),
            center.dy + (radius - 23) * math.sin(angle),
          );
          final outerPoint = Offset(
            center.dx + (radius - 23 + tickLength) * math.cos(angle),
            center.dy + (radius - 23 + tickLength) * math.sin(angle),
          );

          canvas.drawLine(innerPoint, outerPoint, tickPaint);
        }
      }
    }

    /// POINTER
    final pointerStart = Offset(center.dx, center.dy - radius - 23);
    final pointerEnd = Offset(center.dx, center.dy - radius + 20);

    final pointerThumb = Offset(center.dx, center.dy - radius + 25);

    canvas.drawCircle(pointerThumb, 5, pointerThumbPaint);
    canvas.drawLine(pointerStart, pointerEnd, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant WheelPickerPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue;
  }
}
