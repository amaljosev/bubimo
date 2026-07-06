// lib/features/analytics/presentation/widgets/stats_summary_card.dart

import 'package:flutter/material.dart';

import '../../domain/usecases/get_entry_stats.dart';

/// Shows total entries and total words written.
class StatsSummaryCard extends StatelessWidget {
  final EntryStats stats;

  const StatsSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                icon: Icons.menu_book_rounded,
                value: '${stats.totalEntries}',
                label: 'Total entries',
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            Expanded(
              child: _StatColumn(
                icon: Icons.edit_note_rounded,
                value: '${stats.totalWords}',
                label: 'Words written',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 26),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}