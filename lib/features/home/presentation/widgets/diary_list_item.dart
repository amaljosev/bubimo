// lib/features/diary_entry/presentation/widgets/diary_list_item.dart

import 'package:bubimo/core/navigation/debounced_tap.dart';
import 'package:bubimo/core/utils/date_utils.dart';
import 'package:bubimo/features/diary_entry/domain/entities/diary_entry.dart';
import 'package:flutter/material.dart';

/// List tile for a single diary entry on the Home Screen.
///
/// Lives under diary_entry/presentation/widgets/ (intentional deviation
/// from the original plan's home/presentation/widgets/ location). If
/// `home` still has its own copy of this widget, delete it there and
/// import this file instead to avoid two diverging implementations.
///
/// Layout: a plain (no background) date column on the left — day number
/// large, weekday abbreviation small and muted below it — and a single
/// rounded card on the right showing mood emoji + label + score on the
/// first line, then a 2-line preview. Uses `date` (the date the entry is
/// about) rather than `updatedAt` (a DB modification timestamp).
///
/// NOTE on assumed fields (confirm/adjust if your model differs):
///   - `entry.mood!.emoji`  -> String
///   - `entry.mood!.label`  -> String, e.g. "Happy"
///   - `entry.moodScore`    -> double? (0.0–10.0), shown as "x.x/10"
/// `title`/`content`/`preview`/`moodScore` are treated as nullable.
///
/// Card color: reads `colorScheme.surfaceContainerHighest`, which
/// `theme_mapper.dart` explicitly maps from `AppThemeData.surfaceColor`
/// — this is the same field the Create/Edit Custom Theme form's
/// "Surface" tile edits and the live preview (`HomePreviewCard`)
/// renders directly. Previously this read `colorScheme.primaryContainer`,
/// which Flutter auto-derives from `primary` when not explicitly set,
/// producing a tile color completely disconnected from the user's
/// Surface pick (see theme_mapper.dart's ColorScheme construction —
/// primaryContainer is never set there). Do not revert to
/// primaryContainer without also explicitly setting it in
/// theme_mapper.dart.
///
/// Tap handling uses [DebouncedTap] (not a plain `InkWell`) so a fast
/// double-tap on the same tile can't push [onTap]'s destination route
/// twice — see [DebouncedTap]'s doc comment for why this was needed
/// app-wide, not just here.
class DiaryListItem extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  /// Whether to render the built-in day-number/weekday column on the
  /// left. Defaults to true for standalone use. Pass `false` when a
  /// parent list (e.g. [HomePage]'s date-grouped list) already shows
  /// its own date tile once per day, to avoid the date rendering
  /// twice for the same entry.
  final bool showDateColumn;

  const DiaryListItem({
    super.key,
    required this.entry,
    required this.onTap,
    this.showDateColumn = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = entry.title?.isNotEmpty == true ? entry.title! : '(Untitled)';
    final preview = entry.preview?.isNotEmpty == true
        ? entry.preview!
        : (entry.content ?? '');

    // Surface color, straight from the theme — matches what the user
    // picked in the Colors > Surface field and sees in the live
    // preview. No alpha dilution: the preview shows this color at
    // full strength, so the real tile should match exactly.
    final cardColor = colorScheme.surface;
    final onCardColor = colorScheme.onSurfaceVariant;

    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (entry.mood != null) ...[
                Text(
                  entry.mood!.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.mood!.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onCardColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              const Spacer(),
              if (entry.isFavorite)
                Icon(
                  Icons.favorite,
                  size: 14,
                  color: colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onCardColor,
            ),
          ),
        ],
      ),
    );

    return DebouncedTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date column — omitted when a parent list already renders
            // its own date tile (see [showDateColumn] doc above).
            if (showDateColumn) ...[
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    Text(
                      AppDateUtils.dayOfMonthPadded(entry.date),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppDateUtils.weekdayNameShort(entry.date.weekday),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: card),
          ],
        ),
      ),
    );
  }
}