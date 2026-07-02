// lib/features/diary_entry/presentation/widgets/confirm_delete_dialog.dart

import 'package:flutter/material.dart';

/// Shows a confirmation dialog before deleting a diary entry.
///
/// Returns `true` if the user confirmed deletion, `false` if they
/// cancelled, or `null` if the dialog was dismissed some other way (e.g.
/// tapping outside it or the system back gesture) — callers should treat
/// anything other than `true` as "do not delete".
Future<bool?> showConfirmDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete entry?'),
      content: const Text(
        'This entry will be permanently deleted. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}