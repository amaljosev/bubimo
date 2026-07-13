// lib/features/profile/presentation/widgets/analytics_widgets/mood_count_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../diary_entry/domain/entities/mood.dart';

/// Shows how many entries have each mood as a rounded-bar chart, built
/// with fl_chart. Bars are colored by a themed gradient from
/// [ColorScheme.primary] to [ColorScheme.secondary] rather than
/// mood-specific colors, keeping the chart visually consistent with
/// whatever theme the user has selected.
///
/// Uses [ColorScheme.primary]/[ColorScheme.secondary] for the bar
/// gradient (not `tertiary` — this app only ever collects 5 theme
/// colors, and `theme_mapper.dart` maps `tertiary` to the same value as
/// `secondary`, so reaching for `secondary` directly here is equivalent
/// and clearer about intent).
///
/// The touch tooltip uses the same themed-card design as
/// [HeatmapWidget]'s day tooltip and [WritingConsistencyChart]'s point
/// tooltip — [ColorScheme.surface] background, rounded corners, a soft
/// shadow, and a bold label line over a lighter value line — so all
/// three analytics tooltips look and feel identical.
class MoodCountChart extends StatelessWidget {
  final Map<Mood, int> moodCounts;

  const MoodCountChart({super.key, required this.moodCounts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final maxCount = moodCounts.values.isEmpty
        ? 0
        : moodCounts.values.reduce((a, b) => a > b ? a : b);
    final chartMax = maxCount == 0 ? 1.0 : maxCount * 1.2;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moods',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'How you\'ve been feeling in your entries',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.surfaceContainerHigh,
                      tooltipBorderRadius: BorderRadius.circular(12),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tooltipMargin: 12,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final mood = Mood.values[group.x.toInt()];
                        final entryLabel =
                            rod.toY.round() == 1 ? 'entry' : 'entries';
                        return BarTooltipItem(
                          '${mood.label}\n',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.round()} $entryLabel',
                              style: TextStyle(
                                color:
                                    colorScheme.onSurface.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= Mood.values.length) {
                            return const SizedBox.shrink();
                          }
                          final mood = Mood.values[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < Mood.values.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: (moodCounts[Mood.values[i]] ?? 0).toDouble(),
                            width: 22,
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: chartMax,
                              color: colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}