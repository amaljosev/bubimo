// lib/features/diary_entry/presentation/widgets/diary_list_item.dart

import 'package:flutter/material.dart';

import '../../domain/entities/diary_entry.dart';

/// List tile for a single diary entry on the Home Screen.
///
/// Milestone 2: shows the mood emoji (if set) as a leading widget, and
/// switches the trailing date from `updatedAt` (record save timestamp) to
/// `date` (the date the entry is actually about/written for) — more
/// meaningful for a diary list than a DB modification timestamp.
class DiaryListItem extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DiaryListItem({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // deletion handled via bloc; never let Dismissible remove itself
      },
      child: ListTile(
        leading: entry.mood != null
            ? Text(
                entry.mood!.emoji,
                style: const TextStyle(fontSize: 24),
              )
            : null,
        title: Text(
          entry.title.isEmpty ? '(Untitled)' : entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          entry.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatDate(entry.date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );
  }
}