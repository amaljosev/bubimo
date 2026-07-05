// lib/features/shared/presentation/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';

/// Shown on Home when the visible list is empty. Supports two variants:
/// - No entries at all yet (shows a "create your first entry" CTA)
/// - No favorites yet under the current filter (no CTA — the fix is to
///   favorite an existing entry, not create a new one)
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreatePressed;

  /// When true, shows the "no favorites yet" variant instead of the
  /// general "no entries yet" variant.
  final bool isFavoritesFilter;

  const EmptyStateWidget({
    super.key,
    required this.onCreatePressed,
    this.isFavoritesFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavoritesFilter ? Icons.favorite_border : Icons.book_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isFavoritesFilter ? 'No favorites yet' : 'No entries yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isFavoritesFilter
                  ? 'Tap the heart on an entry to add it to your favorites.'
                  : 'Start writing your first diary entry to see it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            if (!isFavoritesFilter) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreatePressed,
                icon: const Icon(Icons.add),
                label: const Text('Write your first entry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}