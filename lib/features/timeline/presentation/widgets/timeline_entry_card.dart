// lib/features/timeline/presentation/widgets/timeline_entry_card.dart

import 'package:flutter/material.dart';

/// Shown under the selected day when it has no diary entries.
///
/// NOTE: the per-entry card that used to live in this file
/// (`TimelineEntryCard`) has been removed — the Timeline day breakdown
/// now reuses the shared `DiaryListItem` widget (see
/// `home/presentation/widgets/diary_list_item.dart`) instead of a
/// bespoke card, so entries look and behave identically across
/// Diary/Timeline/Favorites and there's only one card implementation
/// to maintain.
class TimelineEmptyDayView extends StatelessWidget {
  const TimelineEmptyDayView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_outlined,
                size: 34,
                color: theme.colorScheme.primary.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Nothing written yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to start writing',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}