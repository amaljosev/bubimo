// lib/features/analytics/presentation/widgets/stats_summary_card.dart

import 'package:flutter/material.dart';

import '../../domain/usecases/get_entry_stats.dart';

/// Shows total entries and total words written.
class StatsSummaryCard extends StatelessWidget {
  final EntryStats stats;

  const StatsSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                icon: Icons.menu_book_outlined,
                value: '${stats.totalEntries}',
                label: 'Total Entries',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: _StatColumn(
                icon: Icons.edit_note_outlined,
                value: '${stats.totalWords}',
                label: 'Words Written',
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
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}