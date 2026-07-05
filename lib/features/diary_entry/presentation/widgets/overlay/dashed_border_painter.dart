// lib/features/diary_entry/presentation/widgets/overlay/dashed_border_painter.dart

import 'package:flutter/material.dart';

/// Draws a dashed rectangle border around a selected overlay item
/// (see `TransformableItem`).
///
/// Painted rather than built from `Container`/`DottedBorder`-style
/// widgets so the dash pattern stays crisp regardless of the child's
/// size or rotation transform applied above it in the tree.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5,
    this.dashLength = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength;
  }
}