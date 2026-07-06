// lib/features/analytics/presentation/widgets/heatmap_widget.dart

import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/usecases/get_heatmap_data.dart';

/// GitHub-style 365-day activity heatmap: one column per week, one row
/// per weekday (Sun top, Sat bottom), each cell a filled/unfilled
/// square depending on [HeatmapDay.hasEntry].
class HeatmapWidget extends StatelessWidget {
  final List<HeatmapDay> heatmapData;

  const HeatmapWidget({super.key, required this.heatmapData});

  static const double _cellSize = 12;
  static const double _cellSpacing = 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (heatmapData.isEmpty) {
      return const SizedBox.shrink();
    }

    final weeks = _buildWeeks(heatmapData);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Last 365 days',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // start scrolled to the most recent (right)
              child: Row(
                children: weeks
                    .map((week) => _WeekColumn(
                          days: week,
                          filledColor: colorScheme.primary,
                          emptyColor: colorScheme.surfaceContainerHighest,
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
            _Legend(
              filledColor: colorScheme.primary,
              emptyColor: colorScheme.surfaceContainerHighest,
              textStyle: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Splits the flat, chronologically-ordered [days] list into weekly
  /// columns, padding the first (partial) week with nulls so each
  /// entry lands on the correct weekday row.
  List<List<HeatmapDay?>> _buildWeeks(List<HeatmapDay> days) {
    final firstDate = days.first.date;
    // Dart's DateTime.weekday: Monday=1 ... Sunday=7. Map so Sunday=0.
    final leadingPad = firstDate.weekday % 7;

    final padded = <HeatmapDay?>[
      ...List<HeatmapDay?>.filled(leadingPad, null),
      ...days,
    ];

    final weeks = <List<HeatmapDay?>>[];
    for (var i = 0; i < padded.length; i += 7) {
      final end = (i + 7 <= padded.length) ? i + 7 : padded.length;
      final week = padded.sublist(i, end);
      // Pad the final (partial) week out to 7 for consistent layout.
      weeks.add([
        ...week,
        ...List<HeatmapDay?>.filled(7 - week.length, null),
      ]);
    }
    return weeks;
  }
}

class _WeekColumn extends StatelessWidget {
  final List<HeatmapDay?> days;
  final Color filledColor;
  final Color emptyColor;

  const _WeekColumn({
    required this.days,
    required this.filledColor,
    required this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HeatmapWidget._cellSpacing / 2,
      ),
      child: Column(
        children: days.map((day) {
          final color = day == null
              ? Colors.transparent
              : (day.hasEntry ? filledColor : emptyColor);

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: HeatmapWidget._cellSpacing / 2,
            ),
            child: Tooltip(
              message: day == null
                  ? ''
                  : '${AppDateUtils.toDisplayString(day.date)}'
                      '${day.hasEntry ? ' — wrote' : ''}',
              child: Container(
                width: HeatmapWidget._cellSize,
                height: HeatmapWidget._cellSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3.5),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Small "Less → More" legend row explaining the two cell shades.
class _Legend extends StatelessWidget {
  final Color filledColor;
  final Color emptyColor;
  final TextStyle? textStyle;

  const _Legend({
    required this.filledColor,
    required this.emptyColor,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    Widget cell(Color color) => Container(
          width: HeatmapWidget._cellSize,
          height: HeatmapWidget._cellSize,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.5),
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: textStyle),
        cell(emptyColor),
        cell(filledColor),
        Text('More', style: textStyle),
      ],
    );
  }
}