// lib/features/timeline/presentation/widgets/timeline_day_cells.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Selected day — bold gradient circle with optional mood emoji badge.
class SelectedDayCell extends StatelessWidget {
  final DateTime day;
  final bool hasFav;
  final String mood;

  const SelectedDayCell({
    super.key,
    required this.day,
    required this.hasFav,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = hasFav ? Colors.redAccent : theme.colorScheme.primary;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: hasFav
                  ? [Colors.redAccent, Colors.pink.shade300]
                  : [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.75),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ),
        if (mood.isNotEmpty)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(mood, style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Favorite day — rosy gradient ring + heart badge.
class FavoriteDayCell extends StatelessWidget {
  final DateTime day;
  final String mood;

  const FavoriteDayCell({super.key, required this.day, required this.mood});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.redAccent.withValues(alpha: 0.22),
                Colors.pink.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.redAccent,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 1,
          right: 1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.favorite, size: 8, color: Colors.redAccent),
            ),
          ),
        ),
        if (mood.isNotEmpty)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(mood, style: const TextStyle(fontSize: 9)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Normal entry day — soft tinted circle ring + mood emoji badge.
class EntryDayCell extends StatelessWidget {
  final DateTime day;
  final String mood;

  const EntryDayCell({super.key, required this.day, required this.mood});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.18),
                theme.colorScheme.secondary.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (mood.isNotEmpty)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Text(mood, style: const TextStyle(fontSize: 9)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Today with no entry — dashed border ring.
class TodayEmptyCell extends StatelessWidget {
  final DateTime day;

  const TodayEmptyCell({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      painter: _DashedCirclePainter(color: theme.colorScheme.primary),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: Text(
            '${day.day}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 2;
    const dashCount = 12;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapFraction = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

/// Chevron button used inside the calendar header.
class CalendarChevron extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CalendarChevron({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}