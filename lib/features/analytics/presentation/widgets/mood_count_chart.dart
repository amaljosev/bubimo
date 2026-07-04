// lib/features/analytics/presentation/widgets/mood_count_chart.dart

import 'package:flutter/material.dart';

import '../../../diary_entry/domain/entities/mood.dart';

/// Shows how many entries have each mood as a simple horizontal bar
/// list — emoji, bar sized relative to the highest count, and the
/// number itself. No charting package required.
class MoodCountChart extends StatelessWidget {
  final Map<Mood, int> moodCounts;

  const MoodCountChart({super.key, required this.moodCounts});

  @override
  Widget build(BuildContext context) {
    final maxCount = moodCounts.values.isEmpty
        ? 0
        : moodCounts.values.reduce((a, b) => a > b ? a : b);

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Moods', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...Mood.values.map((mood) {
              final count = moodCounts[mood] ?? 0;
              final fraction = maxCount == 0 ? 0.0 : count / maxCount;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(mood.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 56,
                      child: Text(
                        mood.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 10,
                          backgroundColor:
                              colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}