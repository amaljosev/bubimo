// lib/features/home/presentation/widgets/diary_list_item.dart

import 'package:flutter/material.dart';

import '../../../diary_entry/domain/entities/diary_entry.dart';

/// List tile for a single diary entry on the Home Screen.
///
/// Note: this now lives under diary_entry/presentation/widgets/ rather
/// than home/presentation/widgets/ (the original plan's location) — an
/// intentional deviation. If `home` still has its own copy of this
/// widget, that one should be deleted/replaced with an import of this
/// file to avoid two diverging list-item implementations.
///
/// Shows the mood emoji (if set) as a leading widget, and uses `date`
/// (the date the entry is actually about/written for) rather than
/// `updatedAt` (a DB modification timestamp) — more meaningful for a
/// diary list. `title`/`content`/`preview` are nullable on [DiaryEntry],
/// so they're guarded here rather than assumed non-null.
class DiaryListItem extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const DiaryListItem({
    super.key,
    required this.entry,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = entry.title?.isNotEmpty == true ? entry.title! : '(Untitled)';
    final subtitle = entry.preview?.isNotEmpty == true
        ? entry.preview!
        : (entry.content ?? '');

    return ListTile(
      leading: entry.mood != null
          ? Text(
              entry.mood!.emoji,
              style: const TextStyle(fontSize: 24),
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatDate(entry.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (entry.isFavorite) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.favorite,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}