// lib/features/profile/presentation/widgets/analytics_widgets/writing_consistency_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/date_utils.dart';
import '../../../domain/usecases/analytics_usecases/get_word_count_trend.dart';

/// Line chart of words written/edited per day over the last
/// [kWordCountTrendDays] days.
///
/// Deliberately separate from the heatmap and mood chart: the heatmap
/// shows presence/absence (did you write), the mood chart shows an
/// all-time category breakdown (what mood), and this chart shows
/// volume-over-time (how much) — three different questions, none
/// redundant with each other.
///
/// Uses `fl_chart`'s `LineChart` — no new package dependency, matching
/// the existing `BarChart` usage in [MoodCountChart].
///
/// The touch tooltip uses the same themed-card design as
/// [HeatmapWidget]'s day tooltip and [MoodCountChart]'s bar tooltip —
/// [ColorScheme.surface] background, rounded corners, and a bold label
/// line over a lighter value line — so all three analytics tooltips
/// look and feel identical.
class WritingConsistencyChart extends StatelessWidget {
  final List<WordCountDay> wordCountTrend;

  const WritingConsistencyChart({super.key, required this.wordCountTrend});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (wordCountTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxWords = wordCountTrend
        .map((d) => d.wordCount)
        .reduce((a, b) => a > b ? a : b);
    // Keep a sane visual ceiling even on a totally empty trend, and
    // leave headroom above the tallest day so its dot/label isn't
    // clipped against the top edge.
    final chartMaxY = maxWords == 0 ? 10.0 : maxWords * 1.2;

    // Label only a handful of days along the x-axis (not all 30) to
    // avoid an unreadable cramped axis.
    final labelEvery = (wordCountTrend.length / 5).ceil().clamp(1, 30);

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
              'Writing consistency',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Words written per day, last $kWordCountTrendDays days',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: chartMaxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.surfaceContainerHigh,
                      tooltipBorderRadius: BorderRadius.circular(12),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tooltipMargin: 12,
                      getTooltipItems: (spots) => spots.map((spot) {
                        final day = wordCountTrend[spot.x.toInt()];
                        return LineTooltipItem(
                          '${AppDateUtils.monthNameShort(day.date.month)} '
                          '${day.date.day}\n',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: '${day.wordCount} words',
                              style: TextStyle(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.85),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
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
                        reservedSize: 28,
                        interval: labelEvery.toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= wordCountTrend.length) {
                            return const SizedBox.shrink();
                          }
                          final date = wordCountTrend[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      curveSmoothness: 0.2,
                      barWidth: 2.5,
                      color: colorScheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.25),
                            colorScheme.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      spots: [
                        for (var i = 0; i < wordCountTrend.length; i++)
                          FlSpot(
                            i.toDouble(),
                            wordCountTrend[i].wordCount.toDouble(),
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