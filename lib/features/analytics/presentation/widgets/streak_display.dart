// lib/features/analytics/presentation/widgets/streak_display.dart

import 'package:flutter/material.dart';

/// Shows current streak and longest streak ever, side by side.
class StreakDisplay extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakDisplay({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StreakCard(
            icon: Icons.local_fire_department,
            label: 'Current Streak',
            value: currentStreak,
            iconColor: Colors.deepOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StreakCard(
            icon: Icons.emoji_events,
            label: 'Longest Streak',
            value: longestStreak,
            iconColor: Colors.amber.shade700,
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color iconColor;

  const _StreakCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              '$value ${value == 1 ? 'day' : 'days'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}